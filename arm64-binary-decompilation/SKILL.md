---
name: arm64-binary-decompilation
description: Use when reverse-engineering ARM64 macOS binaries (Mach-O). Covers vtable tracing via Itanium ABI, float constant decoding from MOV/MOVK pairs and literal pools, struct field mapping from load/store offsets, string-anchored function discovery in stripped binaries, and toolchain selection (llvm-objdump, Ghidra, lldb).
---

# ARM64 Binary Decompilation

## Overview

Recover algorithms from stripped ARM64 macOS binaries by combining string-anchored function discovery, Itanium ABI vtable tracing, and float constant decoding. The primary workflow is: find function names in string constants, trace to their vtables, disassemble Evaluate methods, and decode the math.

## When to Use

- Reverse-engineering ARM64 Mach-O binaries on macOS
- Tracing C++ virtual dispatch in stripped binaries (no DWARF symbols)
- Decoding float/double constants from ARM64 instruction sequences
- Mapping struct field layouts from load/store offsets
- Finding CPU-side parameter math that feeds GPU uniform buffers

## Toolchain

### Quick Start (No Setup Required)

```bash
# Extract ARM64 slice from universal binary
lipo -thin arm64 -output /tmp/binary_arm64 /path/to/binary

# Disassemble a specific address range
llvm-objdump -d --start-address=0xADDRESS --stop-address=0xEND /tmp/binary_arm64

# Dump all string constants
strings -o /tmp/binary_arm64 > strings.txt

# Dump Mach-O sections
otool -l /tmp/binary_arm64 | grep -A5 sectname
```

`llvm-objdump` ships with Xcode. It produces clean ARM64 assembly and is sufficient for targeted function disassembly when you know the addresses.

### Full Toolchain (For Deeper Analysis)

| Tool         | Use For                     | Cost       |
| ------------ | --------------------------- | ---------- |
| llvm-objdump | Targeted disassembly        | Free/Xcode |
| Ghidra 12.0  | Decompiler, xrefs, structs  | Free       |
| lldb         | Dynamic validation          | Free/Xcode |
| Hopper       | Quick interactive browsing  | ~$99       |
| GhidraMCP    | Claude Code ↔ Ghidra bridge | Free       |

**Ghidra setup for large binaries:**
```bash
# Headless import (expect 1-4 hours for 100MB+ binaries)
# Set -Xmx8g or higher in ghidraRun script first
$GHIDRA_HOME/support/analyzeHeadless /tmp/project BinaryName \
  -import /tmp/binary_arm64 \
  -processor AARCH64:LE:64:v8A \
  -analysisTimeoutPerFile 7200 \
  -max-cpu 8
```

Disable Aggressive Instruction Finder and Decompiler Parameter ID on first pass. Enable selectively on functions of interest.

## Core Technique: String-Anchored Function Discovery

Stripped C++ binaries still contain string constants used for logging, registration, and dispatch. These are the primary entry points.

### Step 1: Extract strings and build a source map

```bash
strings -o /tmp/binary_arm64 | grep -E 'cr_|function|stage' > function-strings.txt
# -o gives decimal byte offsets for each string
```

### Step 2: Find string references in code

In Ghidra: Search > For Strings → find target → right-click → References → Show References To. Each xref is a code site that loads the string pointer (typically a registration or dispatch function).

With llvm-objdump: search the disassembly for ADRP+ADD pairs that compute the string's address.

### Step 3: Navigate from registration site to implementation

At the xref, the string is typically passed alongside a function pointer to a registration function. That function pointer is your target — it's the implementation (or setup/dispatch function) for the named operation.

## Core Technique: Itanium ABI Vtable Tracing

C++ binaries compiled with Clang/GCC use the Itanium ABI for vtables and RTTI. This is the key to finding virtual method implementations in stripped binaries.

### Memory Layout

```
typeinfo name:  "24cr_split_tone_function"     (mangled, in __cstring)
                 ↑ length-prefixed class name

typeinfo struct: [vtable_ptr_to___cxxrt1] [name_ptr] [base_class_ptr...]
                 ↑ at some address in __data_const

vtable:          [...] [typeinfo_ptr] [offset] [vfunc0] [vfunc1] [vfunc2] ...
                       ↑ slot[-1]              ↑ slot[0] ↑ slot[1] ↑ slot[2]
```

### Tracing Pattern (Proven on CameraRaw)

1. **Find the typeinfo name string.** Search strings for the class name. The mangled name has a length prefix (e.g., `"24cr_split_tone_function"` for a 24-char class name).

2. **Find the typeinfo struct.** Search the binary for the address of the name string as a pointer value. The typeinfo struct contains `[vtable_ptr] [name_ptr] [base_ptrs...]`. The name pointer is typically at offset +8.

3. **Find the vtable.** Search for the address of the typeinfo struct. The vtable contains `[typeinfo_ptr]` at slot[-1] (one pointer before the vtable's "official" start). The vtable address stored in objects points to slot[0], so the typeinfo pointer is at vtable_address - 8.

4. **Read method pointers.** For classes with an `Evaluate` virtual method:
   - slot[0] = destructor (or first virtual)
   - slot[1-2] = destructor variants
   - **slot[3] = Evaluate** (the primary computation method)
   - **slot[4] = EvaluateInverse** (if the class has one)

   Slot indices depend on the class hierarchy. Verify by disassembling the candidate and checking if the code performs the expected math.

### Critical Gotcha: Mach-O Bind Fixups

**External symbol pointers (bind fixups) appear as small values like 0x10 in static analysis.** These are placeholders that `dyld` resolves at load time. Only internal pointers (rebase fixups) show correct addresses in the binary.

When tracing vtables:
- The first pointer in a typeinfo struct (pointing to `__cxxabiv1::__si_class_type_info`'s vtable) will show as a small value (~0x10). This is normal — it's an external bind.
- The name pointer (offset +8) and base class pointer (offset +16) ARE internal and show correct addresses.
- In the vtable itself, the typeinfo pointer at slot[-1] is internal and correct.

**Rule:** If a pointer value is suspiciously small (< 0x1000), it's likely a bind fixup placeholder. Ignore it and look at the other fields.

## Decoding Float Constants

### Pattern 1: Literal Pool Load (Most Common)

```asm
adrp  x8, #0x1234000     ; Page of literal pool
ldr   s0, [x8, #0x567]   ; Load 4 bytes as float from page+offset
```

Decode: read 4 bytes at address `0x1234567` as IEEE 754 float. Ghidra shows the value automatically. With llvm-objdump, compute the address and read with:

```bash
# Read 4 bytes at offset as float
python3 -c "import struct; f=open('/tmp/binary_arm64','rb'); f.seek(0x1234567); print(struct.unpack('f', f.read(4))[0])"
```

### Pattern 2: Double via MOV/MOVK Pairs

```asm
mov   x8, #0x9680         ; Low 16 bits
movk  x8, #0x9999, lsl #16  ; Bits 16-31
movk  x8, #0x9999, lsl #32  ; Bits 32-47
movk  x8, #0x3FB9, lsl #48  ; Bits 48-63
fmov  d0, x8               ; Move to double register
```

Decode: assemble the 64-bit value from the immediates, then interpret as IEEE 754 double:

```python
import struct

def decode_mov_movk(mov_imm, *movk_pairs):
    """Decode MOV/MOVK sequence to double.
    movk_pairs: [(imm, shift), ...]"""
    val = mov_imm
    for imm, shift in movk_pairs:
        val &= ~(0xFFFF << shift)  # Clear target bits
        val |= (imm << shift)      # Set new bits
    return struct.unpack('d', struct.pack('Q', val))[0]

# Example: 0x3FB999999999999A = 0.1
decode_mov_movk(0x9680, (0x9999, 16), (0x9999, 32), (0x3FB9, 48))
```

### Pattern 3: FMOV Immediate (Limited Range)

```asm
fmov  s0, #1.0    ; Only +/-(1+m/16)*2^e where 0≤m≤15, -3≤e≤4
```

Covers: 0.125, 0.25, 0.5, 1.0, 2.0, 4.0, 8.0, 16.0, 31.0, and values in between. The assembler shows the decoded value directly.

### Common Constants in Image Processing

| Value                  | Meaning                    |
| ---------------------- | -------------------------- |
| 2.2, 0.4545            | Gamma encode/decode        |
| 2.4, 1/2.4             | sRGB gamma                 |
|              0.0031308 | sRGB linear/gamma boundary |
|                  12.92 | sRGB linear slope          |
|                   0.18 | 18% gray (exposure pivot)  |
|                  0.001 | Shadow floor               |
| 1e-10                  | Solver epsilon             |
| 0.2126, 0.7152, 0.0722 | Rec.709 luminance weights  |

## Struct Field Mapping

### Inferring Field Types from Instructions

| Instruction | Width   | Likely Type         |
| ----------- | ------- | ------------------- |
| `ldr s`     | 32-bit  | float               |
| `ldr d`     | 64-bit  | double              |
| `ldr w`     | 32-bit  | int32, uint32, enum |
| `ldr x`     | 64-bit  | pointer, int64      |
| `ldr q`     | 128-bit | float4 (SIMD)       |
| `ldrh w`    | 16-bit  | int16, half-float   |
| `ldrb w`    | 8-bit   | byte, bool          |

### GPU Uniform Struct Population Pattern

Functions that map slider values to GPU parameters follow a consistent pattern:

```asm
; Read slider value from input struct
ldr   s0, [x1, #0x08]    ; slider_struct.field_at_0x08

; Transform (the math we want to extract)
fmul  s0, s0, s1         ; scale
fadd  s0, s0, s2         ; offset

; Write to GPU uniform struct
str   s0, [x0, #0x20]    ; uniform_struct.field_at_0x20
```

**Cross-reference strategy:** Match the output struct's field offsets against the GPU shader IR (which reads the same struct via `getelementptr`). This connects CPU-side math to GPU-side consumption.

## Mach-O Binary Structure

Key sections in ARM64 Mach-O binaries:

| Section                   | Contents                 |
| ------------------------- | ------------------------ |
| `__TEXT,__text`           | Executable code          |
| `__TEXT,__cstring`        | C string constants       |
| `__TEXT,__literal4`       | Float literal pools      |
| `__TEXT,__literal8`       | Double literal pools     |
| `__DATA,__const`          | Vtables, constant data   |
| `__DATA_CONST,__const`    | Read-only relocated data |
| `__DATA,__objc_selrefs`   | ObjC selector references |
| `__DATA,__objc_classrefs` | ObjC class references    |

If `__objc_selrefs` contains Metal selectors (`setBytes:length:atIndex:`, `dispatchThreadgroups:threadsPerThreadgroup:`), the binary uses ObjC Metal API (good — selectors survive stripping). If absent, it uses metal-cpp (harder — virtual calls with no string evidence).

## Dynamic Validation with lldb

Use lldb to confirm static analysis findings:

```bash
lldb -n "Target App"

# Break at a known function address
(lldb) b -a 0xADDRESS

# Trigger the code path (e.g., move a slider), then:
(lldb) register read s0 s1 s2 s3     # Float registers
(lldb) register read d0 d1 d2 d3     # Double registers
(lldb) memory read -s4 -ff -c16 $x0  # Dump struct as 16 floats
(lldb) memory read -s8 -fg -c8 $x1   # Dump as 8 doubles
```

**Use static analysis (Ghidra/llvm-objdump) for:** understanding math, mapping struct layouts, finding all code paths.

**Use dynamic analysis (lldb) for:** confirming which functions execute for a given action, getting concrete parameter values, resolving indirect calls.

## GhidraMCP Integration

For batch analysis, connect Ghidra to Claude Code via MCP:

1. Complete Ghidra import + initial analysis (headless, overnight)
2. Install GhidraMCP plugin in Ghidra
3. Open project in Ghidra GUI (hosts the MCP server)
4. Configure Claude Code MCP settings to connect

**Works well via MCP:** querying decompiled output, following xref chains, batch renaming, extracting float constants.

**Does NOT work well via MCP:** initial large-binary analysis, visual graph navigation, complex multi-step type inference.

## Common Mistakes

| Mistake                                   | Fix                                                              |
| ----------------------------------------- | ---------------------------------------------------------------- |
| Treating small pointer values as real     | Values < 0x1000 are likely Mach-O bind fixup placeholders        |
| Skipping literal pool decode              | Every `ldr s/d` from `adrp+add` is a constant — decode it        |
| Wrong vtable slot for Evaluate            | Slot indices depend on class hierarchy — verify by disassembly   |
| Assuming RTTI exists                      | Check for `__cxxrt1` strings; if absent, use constructor tracing |
| Ignoring ADRP page alignment              | ADRP zeros low 12 bits of PC before adding — compute correctly   |
| Using Frida for float registers on ARM64e | Frida Interceptor cannot read D0-D7; use lldb instead            |
| Full-binary Ghidra analysis on 100MB+     | Takes hours; use selective analysis on target address ranges     |
