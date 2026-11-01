# Budget-Free Adaptation in Variance-Aware Non-Stationary Bandits

**Project status: OPEN RESEARCH PROGRAM — NOT SOLVED.**

This repository studies whether one nonanticipating bandit policy can adapt simultaneously to unknown reward-variance and mean-variation budgets. The motivating open problem is identified in Xiaojin Zhang, *Variance-Aware Non-Stationary Bandits: All-Budget Regret Bounds and Adaptation Costs*, arXiv:2610.26116v1 (19 October 2026).

The paper characterizes supplied-budget minimax rates and proves an adaptation frontier on a disclosed deterministic one-improvement family. It explicitly leaves open a sharp prior-free schedule for the unrestricted noisy model. This repository does not claim to solve that open problem.

## Research question

In an oblivious stochastic multi-armed bandit with selected-arm feedback, what is the Pareto-minimal stationary/dynamic regret profile attainable by one fixed policy that knows the number of arms and horizon but is not given either the cumulative variance envelope \(Q\) or the cumulative variation of the mean reward vector \(B\)?

The target is a single policy's simultaneous guarantees, not the pointwise optimum of a different policy for every budget pair. Definitions and prior-work boundaries are in [docs/RESEARCH_QUESTION.md](docs/RESEARCH_QUESTION.md) and [docs/RELATED_WORK.md](docs/RELATED_WORK.md).

## Kernel-verified Lean milestones

The formal project is pinned to Lean \`v4.36.0-rc2\` and Mathlib tag \`v4.36.0-rc2\`. CI uses \`--wfail\`.

### Published-frontier algebra

\`BudgetFreeBandits/AdaptationFrontier.lean\` formalizes an algebraic corollary of Theorem 5.1 of arXiv:2610.26116v1. Under the theorem's two regret inequalities and the paper's scale assumptions, it proves
\[
r_1\geq \frac{gu}{12},
\qquad u^2=nq,\quad u\geq4,\quad n\leq u.
\]

This does not formalize the stochastic bandit model or the information-theoretic proof of Theorem 5.1. It is an algebraic corollary of the published theorem's hypotheses.

### Positive-noise scalar and finite-PMF layer

- \`BudgetFreeBandits/PositiveNoiseAdaptation.lean\` formalizes the point-spike family's exact scalar mean, variance, variance-budget and discrete one-step KL expressions; Mathlib's common-action-kernel KL cancellation; a one-round two-stage chain-rule adapter; and a conditional competitive-ratio algebra lemma.
- \`BudgetFreeBandits/PositiveNoisePMF.lean\` constructs actual finite PMFs on \`Fin 3\`; defines expectation and variance using integrals against \`PMF.toMeasure\`; proves finite weighted-sum identities; and formalizes the discrete finite KL sum.

The PMF layer does **not** yet identify its discrete KL sum with Mathlib's measure-theoretic \`InformationTheory.klDiv\`. That attempted bridge is preserved as an archived draft, not counted as verified.

Earlier pinned CI runs for the PMF module are [41288057061](https://github.com/2503140kcsk-eng/A/actions/runs/41288057061) and [41288061567](https://github.com/2503140kcsk-eng/A/actions/runs/41288061567).

## Restricted positive-noise mathematical result

[docs/POSITIVE_NOISE_ADAPTATION_THEOREM.md](docs/POSITIVE_NOISE_ADAPTATION_THEOREM.md) gives a two-class, explicitly disclosed finite family in which every arm and round has strictly positive reward variance. The stationary class has \(Q_0=1/4096>0\) and \(B=0\); the changing class has \(3T/64\leq Q\leq T/8\) and \(B=1/4\). Its baseline-to-alternative one-observation KL is \(\log(5/3)\).

For that restricted family, the written gap-counting/Jensen lower argument and a family-specific budget-unaware probe-and-commit policy yield a restricted-family oracle-competitive order
\[
\inf_{\pi\text{ not told }Q,B}\sup_{\nu\in\mathcal F}
\frac{\mathbb E_\nu[R_T]}{\Xi(A,T;Q(\nu),B(\nu))}
=\Theta\!\left((T/A)^{1/6}\right).
\]

**Evidence boundary:** this lower/upper comparison is a mathematical write-up, not a complete Lean formalization. The full finite-history KL induction, the path-counting probability argument, the expected-regret calculation for the policy, and the final comparison with the oracle benchmark remain outside the kernel-checked development. The policy's upper bound uses the disclosed support-marker structure; it is not a general bounded-reward algorithm.

A second, genuinely non-degenerate signal distribution on \(\{3/4,7/8\}\) is derived in [docs/SEPARATED_SIGNAL_EXTENSION.md](docs/SEPARATED_SIGNAL_EXTENSION.md). It replaces the deterministic marker by a signal set disjoint from baseline support, but it still relies on perfect support separation and is not Lean-formalized.

## Unverified proof drafts

The following drafts are preserved under [docs/drafts](docs/drafts) and are deliberately **not** compiled or imported:

- \`docs/drafts/PositiveNoiseMeasureKL.lean.md\`: attempt to connect the finite PMF KL sum to Mathlib's measure-level KL via \`withDensity\` and Radon–Nikodym derivatives.
- \`docs/drafts/SequentialKL.lean.md\`: attempt to induct over full action/reward histories for arbitrary history-dependent randomized policies.

Neither file is a verified theorem. Their latest CI failures and the next proof obligations are documented in the archived files. No \`sorry\`, \`admit\`, or axiom was added to force a green build.

## Independent checks

\`scripts/independent_checks.py\` uses Python's standard library and exact rational arithmetic to:
- enumerate finite horizon-1-to-5 history-dependent randomized policies with a shared action kernel in both environments, checking the transcript likelihood-ratio identity;
- enumerate pull-time subsets and check the gap-counting/Cauchy–Schwarz inequalities for \(q\leq10\);
- sweep exact rational variance-budget envelopes for both signal constructions.

The script runs before Lean in [\`.github/workflows/lean.yml\`](.github/workflows/lean.yml). It is a finite regression test, not a proof over all horizons or policies.

## Repository map

- \`BudgetFreeBandits/AdaptationFrontier.lean\` — published-frontier algebraic corollary.
- \`BudgetFreeBandits/PositiveNoiseAdaptation.lean\` — scalar identities, Mathlib KL adapters, and conditional ratio algebra.
- \`BudgetFreeBandits/PositiveNoisePMF.lean\` — finite PMFs, integral-based moments, and discrete KL sum.
- \`scripts/independent_checks.py\` — exact-rational finite regression tests.
- \`docs/POSITIVE_NOISE_ADAPTATION_THEOREM.md\` — restricted positive-noise family and written upper/lower arguments.
- \`docs/SEPARATED_SIGNAL_EXTENSION.md\` — non-degenerate, support-separated signal extension.
- \`docs/drafts/\` — archived, explicitly unverified Lean drafts.
- \`docs/RELATED_WORK.md\` — literature audit and novelty guardrails.
- \`docs/RESEARCH_ROADMAP.md\` — remaining proof and research milestones.
- \`docs/TOOL_ROLES.md\` — roles and actual execution boundaries of mathematical tools.
- \`docs/PROGRESS_LOG.md\` — verification history and remaining tasks.

## Verification

From a clean checkout:

\`\`\`sh
lake exe cache get
lake build
\`\`\`

**Current PR-head CI: PASS.** The exact independent checks and pinned Lean/Mathlib build with `--wfail` both passed on current head `a16ee752b4fd5b66a22af33a78941b1efab6faed` in [GitHub Actions run 41299670148](https://github.com/2503140kcsk-eng/A/actions/runs/41299670148). The four commits after the source-cleanup commit `8d777022` modify documentation only; the compiled Lean source, toolchain, Lake files, test script, and workflow are unchanged. A written proof, symbolic calculation, solver output, or AI explanation is not counted as Lean-verified until the pinned kernel build succeeds.

## Evidence policy

- **PROVED:** kernel-checked Lean theorem, with exact source and CI run linked.
- **REPRODUCED:** independently reproduced finite computation or published result, with assumptions and script.
- **CONJECTURE:** candidate statement not yet proved.
- **OPEN:** precise target without an accepted proof in this repository.
- **BLOCKED:** missing prerequisites or failed verification.

The unrestricted unknown-\((Q,B)\) adaptation problem remains **OPEN**. Publication-level novelty for the restricted positive-noise family remains **UNVERIFIED**.

## Primary source

- https://arxiv.org/abs/2610.26116
- https://arxiv.org/html/2610.26116v1

## Repository slug

The project title is set above. Repository slug is still \`2503140kcsk-eng/A\); this session's GitHub connector does not expose repository renaming, so the slug must be changed through GitHub repository settings.
