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
- Wolfram symbolic checks found no counterexample to the algebraic denominator estimate or the bound (d_g\leq32g^2/3) on (0<g\leq1/4); exact inputs/outputs are recorded in `docs/EXPERIMENT_LOG.md`.
- **Important:** this two-environment KL inequality alone does not prove an adaptation penalty, because a policy that knows Q and B still may not know the improved arm or change time.

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


## 2026-11-01 — positive-noise two-budget adaptation milestone

### New environment family

Added docs/POSITIVE_NOISE_ADAPTATION_THEOREM.md and BudgetFreeBandits/PositiveNoiseAdaptation.lean.

For \(A\ge2\), \(T\ge32A\), let \(n=A-1\), \(K=\lfloor T/2\rfloor\), \(q=K-1\), \(g=1/8\), \(\varepsilon=2/5\), and \(s_T^2=1/(4096T)\). The baseline uses positive-variance two-point laws with means \(1/2\) on arm 1 and \(3/8\) on all challengers. A challenger changed at \(\tau\in[2,K]\) becomes a mixture that places probability \(2/5\) on a uniquely detectable reward 1.

Exact environment values:
- Every arm and round has strictly positive variance.
- Baseline budgets: \(Q_0=1/4096>0\), \(B_0=0\).
- Alternative budgets: \(3T/64\le Q_{a,\tau}\le T/8\), \(B_{a,\tau}=1/4\).
- One-observation KL in the baseline-to-alternative direction: \(\log(5/3)\).
- A common adaptive action kernel contributes zero conditional KL; Mathlib's pinned KL composition-product identities give the one-round chain decomposition.

### Family-specific adaptation theorem

A coupling until the first marked pull, followed by a pathwise count of gaps between challenger pulls, yields
\[
r_0\le gnq/2\ \Longrightarrow\
r_1\ge\frac{g^2nq}{8(r_0+gn)}.
\]
For the same disclosed finite family, a single policy that is not told \(Q,B\) samples challengers with probability \(p=(A/T)^{5/6}\) until observing the unique reward-1 signal, then commits. Its alternative regret bound explicitly includes both pre-change probing regret \(gpT\) and post-change detection delay \(2gn/(p\varepsilon)\). Against the supplied-budget benchmark \(\Xi(A,T;Q,B)\), the family-specific competitive ratio is bounded above by \(4(T/A)^{1/6}\); the lower-bound reduction gives a constant multiple of \((T/A)^{1/6}\). Thus the restricted-family order is \(\Theta((T/A)^{1/6})\).

**Scope:** this is not the unrestricted Pareto frontier over all bounded stochastic environments. The upper algorithm exploits the disclosed spike-family structure. The finite-horizon KL induction, gap-counting argument, and expected-regret analysis are documented mathematical proofs, not yet end-to-end Lean proofs.

### Lean verification status

The new Lean module covers exact means, variances, variance-budget scalar bounds, one-step KL algebra, the common action-kernel KL cancellation adapter, the one-round KL chain adapter, and a final scalar competitive-ratio lemma. The first CI attempt failed on noncomputable real definitions and proof-script issues; those were corrected and the lower-ratio proof was split into a smaller product-bound lemma. Latest CI run for code commit 33c09331ee235b1b460bf740a9d8f0cbab27eab4 is being checked. Do not mark this module PASS until the pinned Lean v4.36.0-rc2 --wfail run succeeds.

### Wolfram checks

Added exact moment/KL calculations, alternative-budget counterexample searches under \(T\ge64\) and \(2\le\tau\le T/2\), and derivatives proving convexity/monotonicity of the gap function to docs/EXPERIMENT_LOG.md. These are symbolic sanity checks, not proofs of the probabilistic coupling or novelty.

### Prior-work check

Unknown-change adaptation alone is not novel: Auer–Gajane–Ortner (COLT 2019), Chen–Lee–Luo–Wei (COLT 2019), and Wei–Luo (COLT 2021) give prior-free results in related stochastic, contextual, and RL settings. The new target remains the two-positive-noise-budget selected-arm family relative to the Zhang (2026) supplied-\((Q,B)\) oracle benchmark, with full-model novelty still provisional.

