# Metrics — claude-marketplace

Aggregate one-line row per archived T3 feature. Written by `lsa-sync` after `lsa-verify` returns clean PASS. Pass/fail counts only — no statistical eval per `vision/VISION.md` §6 *"Adjust #3"*.

Schema: `feature` · `archived` · `accuracy (M/N)` · `facts (M/N)` · `only-required-changes (M/N)` · `notes`.

| Feature | Archived | Accuracy | Facts | Only-required-changes | Notes |
|---|---|---|---|---|---|
| `diagonal-cross-artifact-analysis` | 2026-05-21 | 6/6 (1.00) | 57/60 (~0.95) | 3/3 (1.00) | First end-to-end LSA dogfood loop on this repo; 13 findings + 2 verify warnings logged in archive; 5 items closed in-feature (Findings #3, #4, #7 + warnings W1, W2); 10 findings deferred (#1, #2, #5, #6, #8–#13). |
| `2026-05-21-ears-journey-shape-ac` | 2026-05-21 | 4/4 (1.00) | ≈68/70 (~0.97) | 5/5 (1.00) | EARS + journey-shape AC discipline; dual `lsa-verify` trace predicates; epic `**Covers:**` field. Spec dogfoods its own rule (ACs in EARS form, journey-shaped). 8 KISS/DRY/SRP findings caught by mid-loop `/core:ground-rules` audit — all 8 closed in-feature. 1 verify warning (W1: epic-AC wording drift) closed before sync. Loop cost ≈19 questions vs. prior feature's 11 — driven by OQ2 mid-spec scope expansion (F8 add) + ground-rules audit cleanup. |
