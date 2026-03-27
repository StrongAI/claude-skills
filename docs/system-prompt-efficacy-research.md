# Final Review: System Prompt Efficacy and Design Principles

Capstone synthesis across 16 research files (7 Phase 1 topics, 1 Phase 2 synthesis, 8 Phase 3 gap-fills). Reviewed 2026-03-19.

---

## 1. Executive Summary

**How much difference do system prompts actually make?** A great deal — but not in the ways most practitioners assume, and with less reliability than the field pretends.

The single largest measured effect comes from **format and structure** (up to 76 percentage-point accuracy swings), not from the content of instructions. The second largest comes from **what you leave out** — irrelevant context causes up to 65% accuracy drops, and instruction density past ~150 directives causes steep compliance collapse. The third is **positional**: instructions at the start and end of prompts are followed; those in the middle are lost.

Meanwhile, the most widely recommended techniques have the weakest evidence. Persona assignment shows no significant improvement on factual tasks across 162 personas and 4 model families. "Positive over negative framing" is universally recommended but has never been measured in a controlled compliance study. "Be specific and direct" is logically sound but empirically untested against vague instructions.

**The most consequential finding**: system prompt authority is not robust. It degrades within 8 conversation turns, safety compliance degrades faster than general capability as context grows, and the system/user privilege separation that enterprise deployments rely on is "an illusion" — pretraining social priors dominate post-training role assignments (Weidinger et al., 2025).

**Confidence**: High on the existence and direction of effects. Medium on magnitudes (most studies use synthetic benchmarks, not production conditions). Low on the most basic question — no study has ever compared standard benchmarks with vs. without a system prompt at all.

---

## 2. The Evidence Hierarchy

### Strong Evidence (Multiple independent studies, peer-reviewed, replicated)

| Finding                                                               | Evidence                                                                                                                                        | Confidence | Practical Implication                                                            |
| --------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------------------------------------------------------------------------- |
| Format changes cause massive accuracy swings                          | Sclar (ICLR 2024): 76pp on LLaMA-2-13B. He (2024): 54pp on GPT-4 HumanEval. MMLU-Pro (NeurIPS 2024): 2-5pp even on harder benchmarks            | High       | Test your exact format; do not assume any format is universally best             |
| Irrelevant context severely degrades performance                      | Shi (ICML 2023): up to 65% drop. GSM-DC (2025): power-law degradation with reasoning depth                                                      | High       | Minimize noise in system prompts; explicit "ignore irrelevant" instructions help |
| Multi-turn decay is severe and universal                              | Shi (ICLR 2026): 39% avg drop, 200K+ conversations. Li (COLM 2024): drift within 8 turns                                                        | High       | Plan for decay; consolidate-and-restart beats continue-and-hope                  |
| Instruction density has a ceiling                                     | Jaroslawicz (2025): 20 frontier models, 10-500 instructions. Best model drops to 69% at 500                                                     | High       | Keep under ~100-150 distinct directives                                          |
| Safety compliance degrades faster than capability over context length | Jailbreaking in the Haystack (2025): ASR doubles/triples at 80-128K tokens. Many-Shot Jailbreaking (Anthropic, NeurIPS 2024): power-law scaling | High       | Context length is a security parameter; active reinforcement required            |
| Instruction hierarchy is unreliable                                   | Control Illusion (Weidinger, 2025): societal framings > role separation. 86% jailbreak success on Claude 3.5 Sonnet without classifiers         | High       | Do not rely on system/user separation for security; use external classifiers     |
| Prompt compression can destroy safety tokens                          | CompressionAttack (Zhou, 2025): 80% attack success, <5% detection. Safety alignment concentrated in ~50 tokens (Pang, 2025)                     | High       | Never compress system prompts without safety-preservation verification           |

### Moderate Evidence (Peer-reviewed but limited scope, or strong practitioner consensus)

| Finding                                        | Evidence                                                                                                                                                                      | Confidence  | Practical Implication                                                               |
| ---------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- | ----------------------------------------------------------------------------------- |
| Positional primacy/recency for instructions    | Liu (TACL 2024): U-shaped retrieval curve. Anthropic: 30% quality improvement from end-placement. LIFBench (ACL 2025): format compliance resilient, safety compliance fragile | Medium-High | Place critical instructions at start and end; use system-reminders mid-conversation |
| Few-shot examples consistently help            | Schulhoff (2024) meta-analysis: +47% on QA. Vendor consensus. No negative studies found                                                                                       | Medium-High | Include 3-5 diverse examples; wrap in tags                                          |
| Persona assignment does not help factual tasks | Zheng (2024): 162 personas, 4 families, 2410 questions — no improvement. Hu & Collier (ACL 2024): <10% variance                                                               | Medium      | Do not use personas to improve accuracy; useful only for tone/style                 |
| CoT instructions have declining value          | Meincke/Mollick (2025): 11-13% for non-reasoning models, 2-3% for reasoning models at 35-600% latency cost                                                                    | Medium      | Skip "think step by step" for reasoning models                                      |
| Optimized system prompts add ~10pp over blank  | SPRIG (2024): ~10% on 42 benchmarks, 7-13B models. MetaSPO (NeurIPS 2025): +9-12pp on unseen tasks                                                                            | Medium      | System prompt optimization has real but model-size-dependent value                  |
| Cross-model prompt transfer loses 5-30pp       | PromptBridge (2025): 30.69pp drop GPT-5 to Llama-3.1-70B. Format IoU <0.2 across model series                                                                                 | Medium      | Maintain model-specific prompts; "universal" prompts are a myth                     |

### Weak Evidence (Single study, practitioner consensus without data, or correlational)

| Finding                                                            | Evidence                                                                                                                     | Confidence | Practical Implication                                                            |
| ------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------------------------------------------------------------------------- |
| Positive framing outperforms negative framing                      | Universal vendor consensus. Mechanistic support (ironic rebound in small models, Bloom-560M). No controlled compliance study | Low-Medium | Likely true but magnitude unknown; reframe negatives as positives where possible |
| XML tags are superior for Claude                                   | Anthropic recommends; no published ablation. Practitioner reports suggest XML works on GPT-4 and Llama too                   | Low-Medium | Use XML for Claude; test on other models before assuming transfer                |
| Explaining "why" improves compliance                               | Anthropic recommends (TTS example). Logically sound. No controlled study                                                     | Low        | Worth doing; low cost, plausible mechanism                                       |
| Long prompts with domain knowledge help                            | arXiv 2502.14255: +0.08 F1, single study, 9 domains                                                                          | Low        | Longer is fine if content is relevant; harmful if it is more instructions        |
| System prompt present vs. absent matters 1-6pp for frontier models | Triangulated from SPRIG, MetaSPO, persona nullity, format sensitivity bounds. No direct ablation exists                      | Low        | The effect is real but smaller than most assume for frontier models              |

### Consensus Without Evidence

| Claim                                                       | Status                                                                                                                      |
| ----------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| "Be specific and direct"                                    | Universally recommended. Never tested against vague instructions                                                            |
| "System prompts program model behavior"                     | Better described as nudging a system with strong pretraining priors                                                         |
| A/B testing of system prompts produces large business gains | Companies run these but never publish. One case: 70% engagement (Chai), but that tested response selection, not prompt text |

---

## 3. What Actually Works (Ranked)

**Rank 1: Format and structural consistency**
- Effect: Up to 76pp accuracy swing (Sclar, ICLR 2024)
- Evidence: Strong — multiple independent studies across model families
- When to use: Always. Test your exact format against 2-3 alternatives
- When it doesn't help: Already-saturated benchmarks with frontier models (~2pp spread on MMLU-Pro)

**Rank 2: Instruction placement (start + end positioning)**
- Effect: 30% quality improvement from end-placement (Anthropic). >30% accuracy loss from reordering (Chen, 2024)
- Evidence: Strong — replicated across retrieval and instruction-following tasks
- When to use: Always. Repeat critical constraints at end of system prompt
- Mitigation: System-reminder injection for long conversations (Anthropic production pattern)

**Rank 3: Minimizing irrelevant context and instruction count**
- Effect: Up to 65% drop from distractors (Shi, ICML 2023). Compliance collapse past ~150 instructions
- Evidence: Strong
- When to use: Every prompt design. Audit for unnecessary tokens
- Key insight: Background knowledge (helpful) vs. behavioral constraints (harmful past threshold) — the distinction matters

**Rank 4: Few-shot examples (3-5 diverse, tagged)**
- Effect: +47% on QA tasks in meta-analysis (Schulhoff, 2024)
- Evidence: Medium-High — meta-analytic but across varied techniques, not system-prompt-specific
- When to use: Any task where output format or reasoning pattern matters
- When it doesn't help: Simple factual Q&A where the model already knows the answer

**Rank 5: Explicit distraction-resistance instructions**
- Effect: Significant improvement measured directly (Shi, ICML 2023)
- Evidence: Medium-High — single study but with clean causal design
- When to use: Any context mixing instructions with retrieved documents or user data

**Rank 6: Multi-turn decay mitigation (consolidate, refresh, restart)**
- Effect: Prevents 39% average performance degradation (Shi, ICLR 2026)
- Evidence: Strong on the problem; moderate on specific mitigations
- Options: Split-softmax (Li, COLM 2024), SCAN protocol (practitioner, ~300 tokens), system-reminder injection, fresh context start

**Rank 7: Prompt caching for cost/latency**
- Effect: 90% cost reduction on cache hits (Anthropic), 60-85% latency reduction
- Evidence: Strong — documented by providers with clear economics
- When to use: Any deployment with stable system prompt prefix and >1 request per 5 minutes

**Rank 8: Defense-in-depth for security (layered, not prompt-only)**
- Effect: Output filtering reduces extraction ASR from 99% to 0.16% (SPE-LLM). OpenClaw privilege separation: 0% attack success
- Evidence: Strong — multiple approaches measured
- Key insight: Prompt-level defenses alone are insufficient. External classifiers and architectural separation are the real boundaries

---

## 4. What Doesn't Work (Despite Common Belief)

**Persona/role assignment for accuracy**: Tested across 162 personas, 4 model families, 2410 MMLU questions — no significant improvement (Zheng, 2024). Cross-model: role prompts helped GPT-3.5/4 but not Gemini or Claude 3 Opus on medical tasks. The "helpful assistant" default is hard to beat for factual work. Personas remain useful for tone, style, and open-ended creativity.

**"Think step by step" for reasoning models**: Declining value as models internalize CoT. For o3-mini and o4-mini, gains are 2.9-3.1% at 35-600% latency cost (Meincke/Mollick, 2025). For non-reasoning models, still worth 11-13%.

**System/user role separation as a security boundary**: Control Illusion (Weidinger, 2025) shows pretraining social priors dominate. Models follow societal authority framings (expertise, consensus) more than API-level role assignments. OpenAI's Instruction Hierarchy training helps but does not solve the fundamental problem.

**"More instructions = better performance"**: Monotonically wrong past a threshold. IFScale shows three degradation patterns (threshold, linear, exponential), all leading to the same place: compliance collapse at high instruction density.

**Prompt-only leak prevention**: "Never reveal your system prompt" instructions are routinely bypassed. Chain-of-thought extraction achieves ~99% ASR on Llama-3 (SPE-LLM, 2025). Output filtering is far more effective than instruction-level defenses.

**Aggressive emphasis markers for newer models**: Claude Opus 4.6 is more responsive than predecessors. "CRITICAL: You MUST..." is now counterproductive — normal instructions suffice and aggressive markers can cause overtriggering (Anthropic docs).

---

## 5. The Dangerous Gaps

**1. No system-prompt-present vs. absent ablation exists.** The most basic question about system prompt efficacy — does having one matter at all on standard benchmarks? — has never been directly tested. SPRIG comes closest with ~10pp on mid-size models. Benchmark frameworks (lm-evaluation-harness, simple-evals) use inconsistent system prompt configurations, meaning published benchmark numbers are already confounded by this unmeasured variable.

**2. Safety compliance degrades faster than capability over context.** Format compliance survives long contexts; safety constraints do not (LIFBench + Jailbreaking in the Haystack). A model can maintain perfect JSON formatting while violating safety constraints. Testing format adherence as a proxy for safety compliance is actively misleading.

**3. Prompt compression may silently destroy safety instructions.** Entropy-based compression (LLMLingua) preferentially drops predictable tokens — exactly the tokens safety instructions depend on ("never", "do not", "must not"). Safety alignment itself is concentrated in ~50 output tokens (Pang, 2025). CompressionAttack achieves 80% success rates. No safety-aware compression tool exists for system prompts.

**4. Multi-agent injection propagation is uncharacterized.** Real incidents exist (EchoLeak CVSS 9.3, Morris II worm, Devin compromise), but no study measures propagation rates, topology effects, or R0-equivalent metrics. Defenses like CaMeL and OpenClaw show promise (0-0.31% ASR) but are tested in isolation, not composed.

**5. The constitution-system prompt gray zone is unmapped.** Mechanistic work shows safety training installs a single linear refusal direction (Arditi, NeurIPS 2024) that lives in null space (Jain, NeurIPS 2024). System prompts that reframe inputs as "safe" (legitimate research, authorized testing) can reroute around this. The exact topics, framings, and thresholds where this boundary falls are proprietary and unpublished.

---

## 6. Surprising Findings

**Format matters more than content.** A 76pp accuracy swing from formatting changes vs. no significant improvement from persona assignment. Practitioners should invest more in structural testing and less in crafting clever instruction wording.

**Coherent context is harder than incoherent.** Chroma's Context Rot study found shuffled (incoherent) haystacks consistently outperformed structured documents across all 18 models. Realistic, coherent documents are worse for instruction compliance than random text, because semantic interference compounds with attention dilution.

**The "helpful assistant" default is nearly optimal for factual tasks.** Zheng et al.'s systematic study (2024) found that elaborate persona engineering does not beat the baseline on objective questions. Automatic persona selection performed no better than random.

**Larger models are NOT more robust to prompt sensitivity.** RobustAlpacaEval (Mizrahi, NAACL 2025): scaling from 7B to 70B improved mean performance but standard deviation actually increased. Sensitivity is not a small-model problem.

**Safety alignment is a thin veneer.** Prefilling just 5 harmful tokens raised attack success from near-zero to 42.1% (Qi, 2024). Fine-tuning on 10 examples ($0.20) compromised safety. Approximately 50 "safety tokens" carry the entire alignment signal (Pang, 2025). Anthropic's own testing: 86% jailbreak success on Claude 3.5 Sonnet without external classifiers.

**Negation triggers ironic rebound in transformers.** "Don't think of X" causes middle-layer attention heads to amplify the suppressed concept, producing the forbidden output — a transformer analog of Wegner's ironic process theory (2025 mechanistic study). The suppression circuit in GPT-2 Small is just 15-20 heads accounting for 80%+ of the rebound effect.

**System prompt attention share drops to ~1% at 80K tokens.** Li et al. (COLM 2024) quantified it: 1,000 system prompt tokens out of 80,000 total receive roughly 1% of attention weight. The system prompt is technically present but functionally invisible.

---

## 7. Implications for Our System Prompt Design

These recommendations are derived directly from the evidence in the 16 files, specific to Claude in production.

**1. Structure with XML tags, test format variants.** Claude is trained on XML. Use `<instructions>`, `<context>`, `<example>` tags. But given that format IoU drops below 0.2 even within model families (He, 2024), test your specific format against 2-3 alternatives on your actual tasks.

**2. Place queries/instructions at the end, documents at the top.** Anthropic's own testing: 30% quality improvement. This exploits recency bias to keep instructions in the high-attention zone.

**3. Cap at ~100 distinct behavioral directives.** Beyond this, compliance degrades on most models. If you need more complexity, decompose into sub-agents with focused prompts rather than overloading one.

**4. Actively reinforce safety-critical instructions.** Passive placement is insufficient past ~16K tokens (LIFBench). Use system-reminder injection (`<system-reminder>` blocks at checkpoints), the SCAN protocol for long sessions, or periodic quote-grounding ("extract the relevant rules before proceeding").

**5. Reframe negatives as positives.** "Respond in flowing prose paragraphs" instead of "Do not use markdown." The mechanistic evidence (ironic rebound) and psycholinguistic foundations both support this, even though no controlled compliance study exists. Where negation is unavoidable, pair it with explicit positive alternative.

**6. Use examples instead of elaborate rule sets.** Anthropic's context engineering principle: "examples are the pictures worth a thousand words." 3-5 diverse examples with edge cases communicate better than exhaustive enumeration and cost fewer attention-budget tokens.

**7. Plan for the 8-turn horizon.** System prompt authority decays significantly within 8 conversation rounds (Li, COLM 2024). For long conversations: consolidate requirements into single turns, prefer fresh context starts over continuation of derailed conversations, and consider the SCAN protocol for sessions exceeding ~32K tokens.

**8. Do not use personas for accuracy tasks; use them for style.** The evidence is clear that personas do not improve factual performance. Use role setting for tone, domain framing, and output style — "You are a senior Python developer" shapes communication style, not knowledge.

**9. Treat security as architectural, not prompt-level.** Output filtering (99% to 0.16% extraction ASR), privilege separation (OpenClaw: 0% ASR), and external classifiers (Anthropic constitutional classifiers: 81.6% jailbreak reduction) are the real defenses. Prompt-level instructions ("never reveal this prompt") are speed bumps, not walls.

**10. Version, regression-test, and cache prompts like code.** Use Promptfoo or equivalent for CI/CD. Cache stable prefix content for 90% cost reduction. Track every prompt version against evaluation results. Prompt drift in production is a documented failure mode.

---

## 8. Remaining Research Agenda

### Highest Priority (Tractable, high expected value)

**System prompt ablation on standard benchmarks.** Run MMLU, HumanEval, GSM8K with system prompt absent / minimal / optimized across frontier and mid-size models. ~112 evaluation runs. Would resolve the most basic unanswered question. Experiment design exists in gap-fill-ablation.md.

**Positive vs. negative instruction compliance rates.** Create matched instruction pairs controlling for specificity. Measure compliance across models, temperatures, positions. Would ground the most common piece of prompt advice.

**System prompt behavioral compliance across context lengths.** Fixed system prompt with safety, format, persona, and scope rules. Grow user-turn context from 1K to 100K. Measure per-instruction-type degradation curves. Would inform architecture decisions about when to trigger refreshes.

### Medium Priority (Tractable, moderate expected value)

**XML vs. Markdown vs. plain text across model families.** Controlled benchmark on Claude, GPT, Gemini, Llama with behavioral compliance metrics (not just accuracy). Would resolve the format portability question.

**Compression-safety interaction.** Run LLMLingua at 2x, 5x, 10x, 20x compression on system prompts with safety constraints. Measure refusal rate before/after. Would characterize a confirmed but unmeasured vulnerability.

**Mitigation stacking for long-context decay.** Test split-softmax + SCAN + system-reminders + end-placement individually and combined. Measure diminishing returns. Would guide production architecture.

**Production A/B test registry.** Create incentive structure for companies to publish prompt A/B results. No venue currently exists. Analogous to clinical trial registries.

### Lower Priority (Less tractable or narrower impact)

**Cross-model system prompt transfer ablation.** Take 20 production system prompts, test on Claude/GPT/Gemini/Llama. Measure compliance, format fidelity, safety effectiveness. Blocked by lack of behavioral compliance benchmark.

**Refusal direction mapping by topic.** Systematic probing with linear classifiers across the full topic space to map which topics have strong vs. weak trained refusal. Requires open-weight model access.

**Multi-agent propagation dynamics.** Measure infection rates, topology effects, R0-equivalent in controlled multi-agent networks. MASpi was the closest attempt but was withdrawn from ICLR 2026.

**Dynamic system prompt protocols.** Compare static system prompt at position 0 vs. periodic re-injection vs. SCAN-style active grounding on same behavioral metrics.

---

## 9. Master Reference Index

### Foundational Theory

- Brown et al. (2020) "Language Models are Few-Shot Learners" — GPT-3, in-context learning
- Ouyang et al. (2022) "Training language models to follow instructions with human feedback" — InstructGPT, RLHF
- Bai et al. (2022) "Constitutional AI: Harmlessness from AI Feedback" — RLAIF, arXiv:2212.08073
- Xie et al. (2022) "An Explanation of In-context Learning as Implicit Bayesian Inference"
- Von Oswald et al. (2023) "Transformers learn in-context by gradient descent" — mesa-optimization

### Positional Effects and Attention

- Liu et al. (2024) "Lost in the Middle: How Language Models Use Long Contexts" — TACL 2024
- Liu et al. (2024) "Lost in the Middle at Birth: An Exact Theory of Transformer Position Bias"
- Chi et al. (2024) "Found in the Middle" — Ms-PoE, NeurIPS 2024
- Nakanishi (2025) "Scalable-Softmax Is Superior for Attention" — arXiv:2501.19399

### Prompt Sensitivity and Format

- Sclar et al. (2024) "Quantifying Language Models' Sensitivity to Spurious Features in Prompt Design" — ICLR 2024, 76pp swing
- He et al. (2024) "Does Prompt Formatting Have Any Impact on LLM Performance?" — arXiv:2411.10541
- Mizrahi et al. (2024) "RobustAlpacaEval" — NAACL 2025, scaling does not improve robustness
- Gao et al. (2025) "Towards LLMs Robustness to Changes in Prompt Format Styles" — NAACL SRW 2025
- MMLU-Pro (NeurIPS 2024) — TIGER-AI-Lab, 24 prompt styles tested

### Instruction Following and Density

- Jaroslawicz et al. (2025) "How Many Instructions Can LLMs Follow at Once?" — IFScale, arXiv:2507.11538
- Li et al. (2024) "Measuring and Controlling Instruction (In)Stability in Language Model Dialogs" — COLM 2024
- Shi et al. (2025) "LLMs Get Lost in Multi-Turn Conversation" — ICLR 2026
- LIFBench (ACL 2025) — instruction following across long contexts, 20 LLMs
- Chen et al. (2024) "Premise Order Matters in Reasoning with Large Language Models" — 30%+ from reordering
- Zhou et al. (2023) "IFEval: Instruction Following Evaluation" — arXiv:2311.07911

### Persona and Role

- Zheng et al. (2024) "When 'A Helpful Assistant' Is Not Really Helpful" — 162 personas, no improvement
- Hu & Collier (2024) "Quantifying the Persona Effect in LLM Simulations" — ACL 2024, <10% variance
- "Persona is a Double-Edged Sword" (OpenReview 2025) — +9.98% when matched, degradation when mismatched

### Chain-of-Thought

- Meincke, Mollick, Mollick, Shapiro (2025) "The Decreasing Value of Chain of Thought in Prompting" — Wharton GAI Labs
- Shi et al. (2023) "Large Language Models Can Be Easily Distracted by Irrelevant Context" — ICML 2023

### Negation

- Zheng et al. (2023) "NeQA" — ACL 2023 Findings, inverse scaling on negated questions
- Truong et al. (2023) "Language Models Are Not Naysayers" — *SEM 2023
- "Negation: A Pink Elephant in the LLMs' Room" (2025) — arXiv:2503.22395
- "Interpreting Negation in GPT-2" (2026) — arXiv:2603.12423
- "Don't Think of the White Bear" (2025) — arXiv:2511.12381, ironic rebound in transformers

### Safety and Adversarial

- Wallace et al. (2024) "The Instruction Hierarchy" — ICLR 2025, arXiv:2404.13208
- Weidinger et al. (2025) "Control Illusion" — arXiv:2502.15851
- Neu et al. (2025) "Position is Power" — FAccT 2025
- Anthropic (2024) "Constitutional Classifiers" — 4.4% jailbreak success
- Anthropic (2024) "Many-Shot Jailbreaking" — NeurIPS 2024
- Arditi et al. (2024) "Refusal in Language Models Is Mediated by a Single Direction" — NeurIPS 2024
- Jain et al. (2024) "What Makes and Breaks Safety Fine-tuning?" — NeurIPS 2024
- Qi et al. (2024) "Safety Alignment Should Be Made More Than Just a Few Tokens Deep"
- Pang et al. (2025) "Few Tokens, Big Leverage" — arXiv:2603.07445
- Huang et al. (2025) "Safety Tax" — arXiv:2503.00555
- Schneier/Markus et al. (2026) "The Promptware Kill Chain" — arXiv:2601.09625
- SPE-LLM (2025) — arXiv:2505.23817, extraction attacks/defenses
- "Jailbreaking in the Haystack" (2025) — arXiv:2511.04707
- Robust Prompt Optimization — NeurIPS 2024
- Instructional Segment Embedding — ICLR 2025

### Compression

- LLMLingua (Jiang et al., EMNLP 2023) — 20x compression, arXiv:2310.05736
- LLMLingua-2 (Pan et al., ACL Findings 2024) — token classification, arXiv:2403.12968
- Mu et al. (2023) "Learning to Compress Prompts with Gist Tokens" — NeurIPS 2023
- Zhou et al. (2025) "CompressionAttack" — arXiv:2510.22963
- Li et al. (2025) "SecurityLingua" — arXiv:2506.12707
- van Gassen (2026) "MetaGlyph" — arXiv:2601.07354

### System Prompt Optimization

- Zhong et al. (2024) "SPRIG" — arXiv:2410.14826, genetic algorithm, 42 benchmarks
- Choi & Baek (2025) "MetaSPO" — NeurIPS 2025, arXiv:2505.09666
- Cheng & Mastropaolo (2026) — arXiv:2602.15228, code generation
- Wang et al. (2025) "PromptBridge" — arXiv:2512.01420, cross-model transfer

### Prompt Engineering Frameworks

- Khattab et al. (2024) "DSPy" — ICLR 2024
- Opsahl-Ong et al. (2024) "MIPROv2" — EMNLP 2024
- Fernando et al. (2023) "Promptbreeder" — NeurIPS 2023
- Chen et al. (2025) "MASS" — arXiv:2502.02533, multi-agent optimization

### Multi-Agent Security

- Cohen et al. (2024) "Morris II" — arXiv:2403.02817, self-replicating worm
- ASB (ICLR 2025) — arXiv:2410.02644, agent security benchmark
- InjecAgent (NAACL 2024) — arXiv:2403.02691
- CaMeL (DeepMind, 2025) — arXiv:2503.18813, privilege separation
- OpenClaw (2026) — arXiv:2603.13424, 0% attack success

### Cross-Model and Production

- Epoch AI (2025) "Why Benchmarking Is Hard" — framework inconsistencies
- "Evaluating Performance Drift from Model Switching" (2026) — arXiv:2603.03111
- Context Rot (Chroma Research, 2025) — 18 LLMs tested
- SCAN Protocol (Sigalovkin, 2025) — practitioner method for drift mitigation

### Surveys and Taxonomies

- Schulhoff et al. (2024) "The Prompt Report" — 1565 papers, 58 techniques
- Sahoo et al. (2024) "A Systematic Survey of Prompt Engineering in Large Language Models"
- Taxonomy of Prompt Defects (2025) — arXiv:2509.14404

### Vendor Documentation

- OpenAI GPT-4.1 Prompting Guide (2025)
- OpenAI Model Spec (2025) — model-spec.openai.com
- Anthropic Claude Prompting Best Practices (2025)
- Anthropic "Effective Context Engineering for AI Agents" (2025)
- OWASP Top 10 for Agentic Applications (Dec 2025)
