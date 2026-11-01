# Progress log

## 2026-11-01 — research project initialized and first formal milestone verified

### Repository and project setup
- Confirmed `2503140kcsk-eng/A` is public and the connected GitHub account has admin/push permission.
- Created branch `research/budget-free-variance-aware-bandits`.
- Changed the README title to **Budget-Free Adaptation in Variance-Aware Non-Stationary Bandits**.
- Added the research question, literature audit, roadmap, tool-role document, and positive-noise lower-bound candidate.
- Created research issue #1 and draft PR #2.
- The repository slug remains `A`: the connected GitHub actions do not expose the repository-rename endpoint. The display/project title is changed in README; slug rename still requires GitHub repository Settings.

### Literature and problem selection
- Read Xiaojin Zhang, arXiv:2610.26116v1, submitted 19 October 2026.
- Recorded the distinction between the supplied-(Q,B) minimax rate and the still-open prior-free noisy adaptation problem.
- Identified Karnin–Anava (NeurIPS 2016) as prior work on variation-adaptive bandits; the project therefore does not claim unknown-variation adaptation alone as new.
- Separated the 2026 unknown-switching-comparator result (arXiv:2609.13547) from this stochastic dynamic-best-arm problem.
- Defined the main target as the Pareto frontier of simultaneous stationary/dynamic regret profiles attainable by a single policy that does not know Q or B.

### Formal verification completed
- Pinned Lean `v4.36.0-rc2` and matching Mathlib tag `v4.36.0-rc2`, with a committed Lake manifest.
- Added `BudgetFreeBandits/AdaptationFrontier.lean`.
- Formalized the algebraic consequence of Theorem 5.1: from its two stated regret inequalities and the scale assumptions (u^2=nq), (u\geq4), (n\leq u), derive (r_1\geq gu/12).
- Fixed CI setup failures (manifest missing, Lean package-name format, default target), then fixed the proof's strict-to-weak inequality conversion and an unused-variable warning.
- **Verified:** GitHub Actions run [41280700093](https://github.com/2503140kcsk-eng/A/actions/runs/41280700093), commit `cb8d1daab95f1da9aa3ec7d26fb8590110e854a7`, completed successfully with `--wfail`. The theorem module and root library built under the pinned toolchain.

**Scope limitation:** this Lean result formalizes only an algebraic corollary of a published preprint theorem. It does not formalize that paper's stochastic bandit model or the information-theoretic proof of Theorem 5.1, and it is not a new bandit lower bound.

### Positive-noise research lead
- Added `docs/NOISY_LOWER_BOUND_CANDIDATE.md` with a Bernoulli one-change family and a candidate KL/Pinsker lower-bound argument.
- Corrected the change time to (\tau\in\{2,\ldots,T\}), because the project's variation budget excludes an initial-vector change.
- In this family, the variance envelope is (Q=T/4) and a single consecutive mean change has (B=2g).
- **Not verified:** the KL chain-rule argument for arbitrary adaptive randomized policies still needs a careful measure-theoretic proof, formalization, and novelty audit. The candidate is not counted as a theorem.

### Current research status
- The unrestricted noisy adaptation problem remains **OPEN / NOT SOLVED**.
- No prior-free policy attaining the optimal simultaneous profile has been constructed.
- No matching general positive-noise lower bound or complete Pareto characterization has been established.
- No experiment is represented as having run unless its output is committed and independently reproducible.

### Next research tasks
1. Formalize the finite-horizon Bernoulli interaction transcript and verify the adaptive KL chain rule.
2. Check the candidate KL/Pinsker inequality against closest bandit lower-bound literature.
3. Extend the model definitions in Lean/Mathlib: action kernels, observed-history filtration, (Q), (B), and dynamic pseudo-regret.
4. Develop a prior-free upper-bound candidate and compare it against the attainable-profile lower bounds.
5. Keep PR #2 in draft until the complete proof assumptions and CI evidence are reviewed.
