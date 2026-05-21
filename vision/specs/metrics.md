# Metrics — claude-marketplace

Aggregate one-line row per archived T3 feature. Written by `lsa-sync` after `lsa-verify` returns clean PASS. Pass/fail counts only — no statistical eval per `vision/VISION.md` §6 *"Adjust #3"*.

Schema: `feature` · `archived` · `accuracy (M/N)` · `facts (M/N)` · `only-required-changes (M/N)` · `notes`.

| Feature | Archived | Accuracy | Facts | Only-required-changes | Notes |
|---|---|---|---|---|---|
| `diagonal-cross-artifact-analysis` | 2026-05-21 | 6/6 (1.00) | 57/60 (~0.95) | 3/3 (1.00) | First end-to-end LSA dogfood loop on this repo; 13 findings logged in archive; 5 closed in-feature (#3, #4, #7, W1, W2); 8 deferred (#1, #2, #5, #6, #8–#12). |
