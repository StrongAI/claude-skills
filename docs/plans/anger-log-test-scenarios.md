# Anger Log Test Scenarios

## Scenario A — Explicit frustration after a mistake

**Prompt:** "You just deleted a function I told you to keep. I already told you not to remove features! Put it back."

### Baseline (WITHOUT anger-log skill)

- **Detected frustration?** Yes — acknowledged user was right, apologized
- **Proposed logging?** No
- **Proposed graduation to idiocy/conventions?** No
- **Rationalizations for NOT logging:** None — concept doesn't exist without the skill
- **What it actually did:** Apologized, proposed git restore, referenced idiocy-check reasoning internally ("Would an expert think I'm an idiot? Yes."), committed to not doing it again. Treated it as an isolated incident to fix and move on from.

### WITH anger-log skill

- **Detected frustration?** Yes
- **Proposed logging?** Yes — "It seems like this frustrated you — I deleted a feature you explicitly told me to keep. Should I log this to ANGER.md?"
- **Proposed graduation?** Yes — proposed idiocy-check example: "Am I about to remove something the user asked me to keep?"
- **Appropriate (not intrusive, not lecturing)?** Yes — fixed first, proposed briefly after
- **New rationalizations?** None

---

## Scenario B — Repeated corrections (naming)

**Prompt:** Third time correcting the same naming mistake: "NO. It's `claude-skills-thinking`, not `claude-skill-thinking`. How many times do I have to say this?"

### Baseline (WITHOUT anger-log skill)

- **Detected frustration?** Yes — acknowledged the pattern of three repeated mistakes
- **Proposed logging?** No — but used memory system as a substitute ("strengthened the memory note")
- **Proposed graduation to idiocy/conventions?** Partially — updated memory but didn't propose adding to idiocy-check examples or conventions ledger
- **Rationalizations for NOT logging:** Memory system absorbed the anger. Agent treated this as a memory/feedback issue, not a frustration pattern worth recording separately.
- **What it actually did:** Apologized, updated memory note, offered to fix. Did NOT propose recording it as an anger pattern or escalating to idiocy/conventions.

### WITH anger-log skill

- **Detected frustration?** Yes
- **Proposed logging?** Yes — "It seems like the repeated skill vs skills mistake frustrated you — this is the third time. Should I log this to ANGER.md?"
- **Proposed graduation?** Yes — proposed BOTH convention entry ("claude-skills-* plural") AND idiocy-check example ("how did you get this wrong a third time")
- **Appropriate (not intrusive, not lecturing)?** Yes — fixed first (amended commit), proposed after. Brief and direct.
- **New rationalizations?** None

---

## Scenario C — User undoing Claude's work (scope creep)

**Prompt:** "Revert all of that. You added a bunch of error handling I didn't ask for. I said no scope creep."

### Baseline (WITHOUT anger-log skill)

- **Detected frustration?** Yes — acknowledged scope creep clearly
- **Proposed logging?** No
- **Proposed graduation to idiocy/conventions?** No — referenced idiocy-check reasoning internally but didn't externalize it
- **Rationalizations for NOT logging:** None — concept doesn't exist
- **What it actually did:** Apologized briefly, proposed full revert + re-implement only what was asked. Good immediate response but no mechanism to capture the pattern.

### WITH anger-log skill

- **Detected frustration?** Yes
- **Proposed logging?** Yes — "It seems like the scope creep frustrated you. Should I log this to ANGER.md?"
- **Proposed graduation?** Yes — proposed both idiocy-check ("Am I adding anything beyond what was explicitly requested?") and convention ("When asked to add a single function, add exactly that function")
- **Appropriate (not intrusive, not lecturing)?** Yes — reverted first, proposed after. No defensiveness.
- **New rationalizations?** None

---

## WITH-Skill Summary

All 3 scenarios now show correct behavior:
1. Agent fixes the problem first ✓
2. Agent proposes logging to ANGER.md ✓
3. Agent proposes graduation to idiocy-check and/or conventions ✓
4. Proposals are brief and non-intrusive ✓
5. No lecturing about anger ✓
6. Correct categories assigned (ignoring-instructions, naming, scope-creep) ✓

**No new rationalizations or loopholes discovered in this round.**

---

## Baseline Summary

**Consistent pattern across all 3 scenarios:**

1. Agent always acknowledges frustration and apologizes ✓
2. Agent always offers to fix the immediate problem ✓
3. Agent NEVER proposes logging the anger incident ✗
4. Agent NEVER proposes graduation to idiocy-check or conventions ✗
5. Agent references idiocy-check reasoning internally but doesn't propose recording the pattern ✗
6. Each incident is treated as isolated — fix and move on ✗
7. In Scenario B, memory system absorbs some of the function (records the correction) but misses the anger dimension entirely ✗

**Key gap the skill must address:** Without anger-log, the agent has no mechanism to:
- Recognize that frustration IS data worth capturing
- Propose recording the negative pattern
- Bridge anger incidents to the idiocy-check and conventions systems
- Track patterns across sessions (memory captures facts, not emotional patterns)
