---
name: metal-shader-decompilation
description: Use when reverse-engineering Apple Metal GPU shaders from metallib or AIR bitcode files. Covers extracting shaders from app bundles, disassembling with metal-objdump, reading LLVM IR with AIR intrinsics, decoding hex float constants, and translating shader algorithms to pseudocode.
---

# Metal Shader Decompilation

## Overview

Recover algorithms from compiled Metal GPU shaders by disassembling AIR (Apple Intermediate Representation) bitcode to readable LLVM IR using Apple's `metal-objdump`. There is no AIR-to-MSL decompiler; the output is LLVM IR with `air.*` intrinsics, which must be read directly.

## When to Use

- Reverse-engineering GPU shader algorithms from macOS/iOS apps
- Extracting metallib files from application bundles
- Reading LLVM IR with Metal-specific `air.*` intrinsics
- Translating shader math from IR to pseudocode
- Decoding IEEE 754 hex float constants in LLVM IR

## Toolchain

### Required: Metal Toolchain (ships with Xcode)

```bash
# Install Metal Toolchain (requires Xcode, not just Command Line Tools)
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -downloadComponent MetalToolchain

# Toolchain mounts at:
/Volumes/MetalToolchainCryptex/Metal.xctoolchain/usr/bin/metal-objdump
```

If `metal-objdump` isn't at that path, check:
```bash
xcrun --find metal-objdump        # May work if Xcode is installed
find /Volumes -name metal-objdump  # Find mounted toolchain
```

### Extraction Pipeline

```
App Bundle → metallib (embedded in binary or Resources/) → metal-objdump → LLVM IR
```

#### Step 1: Find the metallib

Metallib files may be:
- Standalone `.metallib` files in `Contents/Resources/`
- Embedded in Mach-O binaries (look for `MTLB` magic bytes)

```bash
# Search for standalone metallib
find /path/to/App.app -name "*.metallib"

# Search for embedded metallib in binary
grep -oba "MTLB" /path/to/binary | head -5
# Returns byte offsets of metallib headers
```

#### Step 2: Extract embedded metallib

```python
# Extract metallib from binary at known offset
with open(binary_path, 'rb') as f:
    f.seek(offset)
    magic = f.read(4)  # Should be b'MTLB'
    # Read metallib size from header (varies by version)
    # Or extract to end of file and let metal-objdump handle it
```

For the brute-force approach: extract from `MTLB` offset to end of file, then trim if metal-objdump complains.

#### Step 3: Disassemble

```bash
# Disassemble ALL shaders in metallib to LLVM IR
/Volumes/MetalToolchainCryptex/Metal.xctoolchain/usr/bin/metal-objdump -d /path/to/shaders.metallib > output.ll

# IMPORTANT: metal-objdump works on .metallib files, NOT raw .air blobs
# Raw AIR sections give "Malformed block" errors
```

The output is standard LLVM IR text with `air.*` intrinsic calls.

## Reading LLVM IR

### Register Naming

```llvm
%7058 = fcmp ogt float %7057, %7056   ; compare: %7057 > %7056
%7059 = select i1 %7058, float %7057, float %7056  ; ternary
```

Registers are numbered (`%1234`) or named (`%result`). Follow the SSA chain: each register is assigned exactly once.

### Common Arithmetic

| IR Pattern                                                        | Meaning            |
| ----------------------------------------------------------------- | ------------------ |
| `%r = fadd float %a, %b`                                          | a + b              |
| `%r = fsub float %a, %b`                                          | a - b              |
| `%r = fmul float %a, %b`                                          | a * b              |
| `%r = fdiv float %a, %b`                                          | a / b              |
| `%r = call float @air.fast_fma.f32(float %a, float %b, float %c)` | a*b + c            |
| `%r = fcmp olt float %a, %b`                                      | a < b (returns i1) |
| `%r = fcmp ogt float %a, %b`                                      | a > b              |
| `%r = select i1 %cond, float %a, float %b`                        | cond ? a : b       |
| `%r = call float @air.fast_exp2.f32(float %x)`                    | 2^x                |
| `%r = call float @air.fast_log2.f32(float %x)`                    | log2(x)            |
| `%r = call float @air.fast_exp.f32(float %x)`                     | e^x                |
| `%r = call float @air.fast_sqrt.f32(float %x)`                    | sqrt(x)            |

### Power Functions via exp2/log2

Metal shaders compute `pow(x, n)` as:
```llvm
%log = call float @air.fast_log2.f32(float %x)
%scaled = fmul float %log, %exponent
%result = call float @air.fast_exp2.f32(float %scaled)
; result = 2^(log2(x) * n) = x^n
```

### Texture Operations

```llvm
; Sample 2D texture
%pixel = call <4 x float> @air.sample_texture_2d.v4f32(
    %struct._texture_2d addrspace(1)* %tex,
    %struct._sampler addrspace(2)* %sampler,
    <2 x float> %coords, ...)

; Extract channels
%r = extractelement <4 x float> %pixel, i32 0  ; R
%g = extractelement <4 x float> %pixel, i32 1  ; G
%b = extractelement <4 x float> %pixel, i32 2  ; B
%a = extractelement <4 x float> %pixel, i32 3  ; A
```

### Struct Access (Uniforms)

```llvm
; Load field from uniform buffer
%ptr = getelementptr inbounds %struct.Uniforms, %struct.Uniforms* %buf, i64 0, i32 3
%value = load float, float* %ptr
; Field index 3 of the Uniforms struct
```

Map field indices to parameter names by correlating with known behavior (e.g., field 3 = vibrance amount if the function is HSLTuner).

### Control Flow

```llvm
br i1 %cond, label %then, label %else   ; conditional branch

then:
  %val1 = ...
  br label %merge

else:
  %val2 = ...
  br label %merge

merge:
  %result = phi float [ %val1, %then ], [ %val2, %else ]  ; merge values
```

PHI nodes merge values from different predecessor blocks. Read as: "result = val1 if we came from %then, val2 if from %else".

## Decoding Hex Float Constants

LLVM IR represents float constants as IEEE 754 hex doubles:

```python
import struct

def decode_hex_float(hex_str):
    """Decode LLVM hex float like '0x3FE2E147A0000000' to Python float."""
    raw = int(hex_str, 16)
    return struct.unpack('d', struct.pack('Q', raw))[0]

# Examples from CameraRaw:
# 0x3FF0000000000000 = 1.0
# 0x4000000000000000 = 2.0
# 0x3FE0000000000000 = 0.5
# 0x3FB999999999999A = 0.1
# 0x3FD5555555555555 = 1/3
# 0x4030000000000000 = 16.0
# 0x3FE999999999999A = 0.8
# 0x3FEAAAAAAAAAAAB0 ≈ 5/6 = 0.8333...
# 0x3FD9999999999998 ≈ 17/42 = 0.4048...
```

**Key pattern**: When you see a decoded float like 0.4047619..., check if it's a simple fraction (17/42) or known color science constant. Common ones:

| Hex                  | Value       | Meaning                 |
| -------------------- | ----------- | ----------------------- |
| `0x400999999999999A` |         3.2 | Common in sRGB matrices |
| `0x4029000000000000` |        12.5 | Near sRGB slope 12.92   |
| `0x3F89374BC6A7EF9E` | 0.012307... | sRGB linear threshold   |
| `0x3FD3333340000000` |  0.30000001 | Luminance weight approx |

## Translation Strategy

### 1. Identify Entry Points

```bash
# List all shader entry points
grep "^0x.*-- " output.ll | head -50
# Format: 0xOFFSET <function_name> -- <demangled_name>
```

### 2. Map Struct Fields

Find the struct type definitions at the top of each function:
```llvm
%struct.UniformsHSLTuner = type { float, i32, i32, float, ... }
```

Correlate field indices with Lightroom slider values by testing known inputs.

### 3. Follow the Math

Start from the output (final store or return) and trace backwards through the SSA chain. Name registers as you go:

```
%7137 = fmul float %sat, %sat        → sat_squared
%7138 = fsub float 1.0, %7137        → sat_attenuation = 1 - sat²
%7139 = fmul float %7138, %hue_wt    → modulation
```

### 4. Recognize Patterns

Common GPU shader patterns in image processing:

- **Sorting network**: Compare-and-swap for RGB → max/mid/min (vibrance, HSL)
- **Trapezoidal windows**: `min(saturate(x), saturate(1 - k*(x - offset)))` for hue weighting
- **Rational formulas**: `a / (1 - b)` to prevent clipping while boosting
- **Parabolic ease**: `x * (2 - x)` for smooth ramp-in near zero
- **Pad approximations**: Polynomial/rational approximations near singularities (e.g., `x^(1/2.4)` near x=0)
- **Soft-light blend**: `2*a*b + a²*(1-2*b)` for color grading
- **Hermite spline**: Piecewise cubic with smooth derivatives at knots

### 5. Write Pseudocode

For each recovered function, write annotated Python with:
- All constants decoded and named
- Step-by-step comments explaining photographic meaning
- References to known color science (sRGB spec, CIE standards, etc.)
- Summary of key algorithm properties at the end

## Common Mistakes

| Mistake                                 | Fix                                                           |
| --------------------------------------- | ------------------------------------------------------------- |
| Using metal-objdump on raw .air blobs   | Only works on .metallib files                                 |
| Missing Xcode (only Command Line Tools) | Full Xcode required for Metal Toolchain                       |
| Ignoring PHI nodes                      | They're the merge points — trace both predecessor blocks      |
| Not decoding hex floats                 | Every constant is hex; decode to find recognizable values     |
| Treating inlined functions as separate  | GPU compiler aggressively inlines; look for repeated patterns |
| Skipping the sorting network            | RGB→max/mid/min sort is fundamental to many color algorithms  |

## Reference: AIR Intrinsics

For complete AIR format documentation, see [metal-air-docs by SamoZ256](https://github.com/AirGuanZ/metal-air-docs). Key intrinsic families:

- `air.sample_texture_*` — texture sampling
- `air.fast_*` — fast math (exp, log, sqrt, fma)
- `air.convert.*` — type conversions (f16↔f32)
- `air.get_thread_position_in_grid` — compute kernel thread ID

## Reference: MetallibSupportPkg Round-Trip

The [dortania/MetallibSupportPkg](https://github.com/acidanthera/MetallibSupportPkg) project demonstrates the complete round-trip: extract AIR → disassemble → modify → reassemble with `metal-as` → repack. This is battle-tested across 78+ releases on macOS system metallibs.
