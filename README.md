# Budget-Free Adaptation in Variance-Aware Non-Stationary Bandits

**Project status: OPEN RESEARCH PROGRAM — NOT SOLVED.**

This repository studies the limits of a single bandit policy that must adapt to both unknown reward-noise and unknown environmental drift. The target is a mathematically precise open problem identified in the 19 October 2026 preprint:

> Xiaojin Zhang, *Variance-Aware Non-Stationary Bandits: All-Budget Regret Bounds and Adaptation Costs*, arXiv:2610.26116v1.

The paper characterizes the minimax rate when both budgets are supplied to the learner, and proves a sharp adaptation frontier on a disclosed deterministic one-improvement family. It explicitly leaves open a sharp prior-free schedule for the unrestricted noisy model. We will not relabel an existing theorem as a new result.

## Research question

In an oblivious stochastic multi-armed bandit with selected-arm feedback, can we characterize the best simultaneous guarantees of a *single policy* that knows the number of arms and horizon but is not given either:

- the cumulative variance envelope (Q), or
- the cumulative variation of the mean reward vector (B)?

The target is the Pareto-minimal boundary of the stationary/dynamic regret profiles attainable by one fixed policy, not the pointwise optimum of a different policy for every budget pair. The project seeks matching upper and lower bounds for this adaptation profile, or a stronger impossibility theorem.

Definitions, conventions, known results, and the exact scope are in [docs/RESEARCH_QUESTION.md](docs/RESEARCH_QUESTION.md). Prior-work exclusions are in [docs/RELATED_WORK.md](docs/RELATED_WORK.md).

## First verified milestone

`BudgetFreeBandits/AdaptationFrontier.lean` formalizes an algebraic corollary of Theorem 5.1 of arXiv:2610.26116v1. Under the theorem's two regret inequalities and the paper's scale assumptions, it proves
[
r_1\geq \frac{gu}{12},
\qquad
u^2=nq,\quad u\geq4,\quad n\leq u.
]

**Lean CI: PASS** — pinned Lean/Mathlib build completed with `--wfail`.

The pinned Lean/Mathlib build passed with `--wfail` in [GitHub Actions run 41281044362](https://github.com/2503140kcsk-eng/A/actions/runs/41281044362), on code/workflow commit `e9e90b8b5c7393352c00de7f27ac91d95ada7f7d`. The subsequent branch commits changed research documents only; the Lean source, Lake files, toolchain, and workflow used by that run are unchanged.

**Important limitation:** this Lean theorem formalizes only the algebraic deduction from the paper's Theorem 5.1. It does *not* formalize the stochastic bandit model, the information-theoretic proof of Theorem 5.1, or a new solution to the unrestricted noisy adaptation problem.

**Positive-noise module CI: PASS** — the expanded Lean module built with Lean v4.36.0-rc2 and --wfail in [GitHub Actions run 41284538301](https://github.com/2503140kcsk-eng/A/actions/runs/41284538301), on commit 74cc24b7dba9aa94acd0556a9f9ca80ed9aeeb75. This verifies only the declarations present in the Lean module; the full finite-history KL induction and the path-counting/algorithm analyses remain outside the kernel-checked development.

## Positive-noise adaptation milestone (restricted family)

`docs/POSITIVE_NOISE_ADAPTATION_THEOREM.md` develops a two-class construction in which **every arm and every round has strictly positive reward variance**. The stationary class has \(Q_0=1/4096>0,\ B=0\); the one-change class has \(3T/64\le Q\le T/8\) and \(B=1/4\). The exact one-observation KL term is \(\log(5/3)\).

For this disclosed finite family, a gap-counting lower bound and a budget-unaware probe-and-commit policy give the same restricted-family oracle-competitive order:
\[
\inf_{\pi\text{ not told }Q,B}\sup_{\nu\in\mathcal F}
\frac{\mathbb E_\nu[R_T]}{\Xi(A,T;Q(\nu),B(\nu))}
=\Theta\bigl((T/A)^{1/6}\bigr).
\]
This is a genuine positive-noise adaptation obstruction, **but it is not the unrestricted two-dimensional Pareto frontier**. The policy upper bound uses the disclosed spike-family structure. The finite-history KL induction, gap-counting lemma, and algorithm regret calculation remain written proofs and are not yet kernel-checked end-to-end.

`BudgetFreeBandits/PositiveNoiseAdaptation.lean` formalizes the scalar moments/budgets/KL term, common-action-kernel KL cancellation, one-round chain-rule adapter, and conditional competitive-ratio algebra. `BudgetFreeBandits/PositiveNoisePMF.lean` adds actual finite PMFs and integral-defined means/variances, plus the discrete finite KL sum. `BudgetFreeBandits/PositiveNoiseMeasureKL.lean` is an active proof attempt to identify that discrete value with Mathlib's measure-theoretic `InformationTheory.klDiv`; it is not kernel-verified yet. The complete finite-history induction and path-counting theorem also remain unverified.

The earlier Bernoulli construction remains in [docs/NOISY_LOWER_BOUND_CANDIDATE.md](docs/NOISY_LOWER_BOUND_CANDIDATE.md) as a separate information-theoretic candidate; it is not the current main adaptation construction. Exact symbolic checks and limitations are recorded in [docs/EXPERIMENT_LOG.md](docs/EXPERIMENT_LOG.md).

## Repository map

- `BudgetFreeBandits/AdaptationFrontier.lean` — Lean proof of the published-frontier algebraic corollary.\n- `BudgetFreeBandits/PositiveNoiseAdaptation.lean` — scalar moment/KL identities, Mathlib KL-kernel adapters, and conditional competitive-ratio algebra.\n- `BudgetFreeBandits/PositiveNoisePMF.lean` — finite PMFs, true-measure expectations/variances, and discrete KL sum.\n- `BudgetFreeBandits/PositiveNoiseMeasureKL.lean` — current measure-level KL bridge draft; not yet CI-verified.\n- `BudgetFreeBandits/SequentialKL.lean` — finite-history KL induction draft; deliberately excluded from root imports until it type-checks.\n- `scripts/independent_checks.py` — exact-rational finite regression tests, automatically run before Lean CI.\n- `docs/POSITIVE_NOISE_ADAPTATION_THEOREM.md` — positive-noise two-budget family, path-counting lower bound, family-specific budget-unaware algorithm, and scope limitations.
- `docs/RESEARCH_QUESTION.md` — model definitions, Pareto-profile target, scope, and non-goals.
- `docs/RELATED_WORK.md` — literature audit and novelty guardrails.
- `docs/RESEARCH_ROADMAP.md` — phased work plan and acceptance criteria.
- `docs/NOISY_LOWER_BOUND_CANDIDATE.md` — unproved positive-noise lower-bound candidate.
- `docs/EXPERIMENT_LOG.md` — exact symbolic checks and evidence boundary.
- `docs/PROGRESS_LOG.md` — completed work, verification links, and next tasks.
- `docs/TOOL_ROLES.md` — roles and limits of the connected open-source tools.
- `.github/workflows/lean.yml` — Lean build on pushes and pull requests.

## Verification

The formal project is pinned to Lean `v4.36.0-rc2` and Mathlib tag `v4.36.0-rc2`. From a clean checkout, run:

```sh
lake exe cache get
lake build
```

The CI build is the authoritative execution check. A written proof, a symbolic calculation, a solver result, or an AI explanation is not counted as Lean-verified until the CI job succeeds.

## Evidence policy

- **PROVED:** kernel-checked Lean theorem, with exact file and CI run linked.
- **REPRODUCED:** independently reproduced computation or published result, with scripts and assumptions.
- **CONJECTURE:** candidate statement not yet proved.
- **OPEN:** precise target with no accepted proof in this repository.
- **BLOCKED:** missing prerequisites or failed verification.

No `sorry`, `admit`, fabricated experiment, unverified CI pass, or paid service is permitted. An incomplete theorem remains incomplete.

## Project title and repository name

The project title is set in this README. The connected GitHub actions available in this session can create branches, files, commits, issues, and pull requests, but do not expose the repository-rename endpoint. Therefore the GitHub repository slug remains `2503140kcsk-eng/A` until it is renamed through GitHub's repository settings.

## Primary source

- https://arxiv.org/abs/2610.26116
- https://arxiv.org/html/2610.26116v1
