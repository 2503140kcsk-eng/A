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



## 2026-11-01 — finite PMFs, exact regression tests, and measure-KL bridge work

### Finite PMFs and moments
- Added BudgetFreeBandits/PositiveNoisePMF.lean.
- Constructs the point-spike baseline and alternative as actual PMF (Fin 3) values with masses (1/2,1/2,0) and (3/10,3/10,2/5).
- Defines expectation and variance as integrals against PMF.toMeasure, proves the finite weighted-sum identities, and kernel-checks exact means, variances, and the discrete KL log-sum.
- **Verified:** pinned Lean v4.36.0-rc2 --wfail builds at [41288057061](https://github.com/2503140kcsk-eng/A/actions/runs/41288057061) and [41288061567](https://github.com/2503140kcsk-eng/A/actions/runs/41288061567), commit 3db509402e407a59d146486b45067980d89982a0

### Independent exact regression test
- Added scripts/independent_checks.py using only Python standard-library Fraction, random, and itertools.
- It enumerates 200 history-dependent randomized policies on horizons 1–5, sharing the same policy kernel in the baseline and alternative. It checks exact transcript likelihood ratios (5/3)^N_a on 53,516 baseline transcripts.
- It exhaustively checks 2,046 pull-time subsets for gap-counting and Cauchy–Schwarz with q<=10.
- It checks 13,231 exact rational (T,tau) pairs for both point-spike and separated-signal variance budgets.
- The checker is run before Lean by .github/workflows/lean.yml. An initial checker run exposed a bug: it sampled separate action kernels in the two environments. The script was corrected to share the policy probability table, and the next workflow's independent-check step passed.
- **Evidence limit:** all these tests are finite regression checks; they do not establish a universal theorem over arbitrary horizons or policy kernels.

### Measure-level KL bridge — still in progress
- Added BudgetFreeBandits/PositiveNoiseMeasureKL.lean to connect the discrete PMF KL expression to Mathlib's actual InformationTheory.klDiv, using Measure.withDensity, Radon–Nikodym derivatives, and Mathlib's klDiv_eq_lintegral_klFun_of_ac.
- The first CI attempts exposed missing imports, the need for an explicit discrete measurable space, and incorrect namespace/argument syntax. The current draft has been revised to use named baseline/alternative measures and explicit constructors.
- **Not yet verified:** do not treat spike_measure_kl_exact as a Lean theorem until the current pinned workflow passes. If it remains unstable, quarantine the module from the root import rather than weaken it with sorry or axioms.

### Finite-history KL induction — still a draft
- BudgetFreeBandits/SequentialKL.lean is not imported by BudgetFreeBandits.lean.
- It attempts to iterate Mathlib's klDiv_compProd_eq_add over recursively defined action/reward histories, but prior CI attempts exposed dependent-history measurable-space and recursion/elaboration issues.
- **Not verified:** this is not a completed all-history adaptive KL proof. The next formalization should first establish a small finite-horizon theorem for a fixed history type and explicit joint transition kernels, then generalize by induction.

### Research and PR state
- The arXiv 2610.26116v1 record and related prior-work sources were rechecked. Gap-counting, coupling-until-detection, Jensen averaging, and probe/commit monitoring are not claimed as new techniques. The current candidate extension is only to positive-variance finite distributions with a perfectly separating signal event.
- The non-degenerate separated-signal construction remains a mathematical note and has not yet been formalized in Lean.
- PR #2 has been returned to **Draft** to match its own acceptance criteria. It is not ready to merge.

## 2026-11-01 — resumed after interrupted measure-KL work

### Failure diagnosis and quarantine
- The measure-level KL bridge and finite-history sequential KL induction both produced real Lean errors under the pinned Lean v4.36.0-rc2 build. The measure-level bridge still had unresolved finite `withDensity` indicator/PMF-mass goals, ENNReal cast equalities for `3/10` and `2/5`, and final `ofReal` KL algebra. The sequential-history theorem still had an unresolved product-history type reduction and proof obligations in probability-measure instances/base cases.
- Neither failed theorem was weakened with `sorry`, `admit`, or an axiom. Their complete source text was preserved as `docs/drafts/PositiveNoiseMeasureKL.lean.md` and `docs/drafts/SequentialKL.lean.md`.
- Removed the two `.lean` files from the compiled source tree and removed the measure-KL draft from the root import file. The compiled root now imports only `AdaptationFrontier`, `PositiveNoiseAdaptation`, and `PositiveNoisePMF`.
- Updated README, PR scope/status, experiment log, and tool-role records to distinguish verified modules from written mathematical arguments and archived Lean drafts.

### Clean pinned verification
- On source-cleanup commit `8d77702299c2c46fe3cd33b2e517efcc34d8b0d6`, GitHub Actions runs [41299399659](https://github.com/2503140kcsk-eng/A/actions/runs/41299399659) and [41299395303](https://github.com/2503140kcsk-eng/A/actions/runs/41299395303) both completed successfully.
- Both runs passed the exact independent finite checks step and the Lean/Mathlib build step with `--wfail` under the pinned Lean `v4.36.0-rc2` and Mathlib `v4.36.0-rc2`.
- Other workflows triggered by earlier sequential file commits also completed successfully: [41299394624](https://github.com/2503140kcsk-eng/A/actions/runs/41299394624), [41299393214](https://github.com/2503140kcsk-eng/A/actions/runs/41299393214), and [41299390204](https://github.com/2503140kcsk-eng/A/actions/runs/41299390204).
- Documentation-only commits after `8d777022` did not modify Lean source, lakefile, manifest, toolchain, script, or workflow. The above pinned build therefore checks the current compiled source tree.

### Independent computations and prior work
- Re-ran Wolfram exact simplification for both point-spike and non-degenerate separated-signal mixtures. The point-spike expressions reduce to mean `5/8`, variance `3/32 + 3 s^2/5`, and forward KL `log(5/3)`. The separated-signal expressions reduce to mean `5/8`, variance `11/224 + 3 s^2/7`, and forward KL `log(7/3)`.
- Rechecked the primary HTML of Zhang, arXiv:2610.26116v1 (19 October 2026). Its Theorem 5.1 / Section 5 already gives the deterministic one-improvement adaptation obstruction and its Corollary 5.5 gives an `Omega((T/A)^(1/4))` loss against supplied-budget deterministic oracle rates. The general unknown-budget low-noise schedule remains open in Section 6.
- Parallel Search and Sider Scholar also surfaced prior work on variation budgets and change detection, including Besbes–Gur–Zeevi, Auer–Gajane–Ortner, Garivier–Moulines, and later adaptive tracking work. Gap counting, coupling-until-detection, Jensen averaging, and probe/commit monitoring are not claimed as new techniques.

### Current status — do not overclaim
- **CI:** the compiled Lean target and finite regression script pass.
- **Kernel-verified:** published-frontier algebraic corollary; positive-noise scalar moments/budgets/KL expression and Mathlib one-round adapters; finite PMFs, their measure-based moments, and discrete finite KL sum.
- **Not kernel-verified:** equality of the discrete PMF KL with Mathlib's measure-level `InformationTheory.klDiv`; arbitrary-history finite-horizon KL induction; the path-counting lower proof; the family-specific policy expected-regret theorem; and the final restricted-family oracle ratio proof.
- **Research status:** the point-spike restricted-family upper/lower result and the non-degenerate support-separated extension remain written mathematical arguments. The latter is not formalized in Lean. Neither is a solution to the unrestricted unknown-`(Q,B)` problem; publication-level novelty remains unverified.
- PR #2 remains Draft and must not be merged as a complete formal solution.