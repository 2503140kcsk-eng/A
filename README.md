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

<badge> <badge label="Lean CI passed" /> </badge>

The pinned Lean/Mathlib build passed with `--wfail` in [GitHub Actions run 41281044362](https://github.com/2503140kcsk-eng/A/actions/runs/41281044362), on code/workflow commit `e9e90b8b5c7393352c00de7f27ac91d95ada7f7d`. The subsequent branch commits changed research documents only; the Lean source, Lake files, toolchain, and workflow used by that run are unchanged.

**Important limitation:** this Lean theorem formalizes only the algebraic deduction from the paper's Theorem 5.1. It does *not* formalize the stochastic bandit model, the information-theoretic proof of Theorem 5.1, or a new solution to the unrestricted noisy adaptation problem.

## Research candidate

`docs/NOISY_LOWER_BOUND_CANDIDATE.md` records a positive-noise Bernoulli one-change construction and a candidate KL/Pinsker lower-bound argument. It is **not yet formally verified or novelty-checked**. Crucially, that two-environment inequality alone does not prove an adaptation penalty, because a learner may still know the numerical budgets while not knowing the improved arm or change time.

Exact symbolic sanity checks and their limits are recorded in [docs/EXPERIMENT_LOG.md](docs/EXPERIMENT_LOG.md).

## Repository map

- `BudgetFreeBandits/AdaptationFrontier.lean` — Lean proof of the first algebraic corollary.
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
