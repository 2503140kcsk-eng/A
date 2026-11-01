# Budget-Free Adaptation in Variance-Aware Non-Stationary Bandits

**Project status: OPEN RESEARCH PROGRAM — NOT SOLVED.**

This repository studies the limits of a single bandit policy that must adapt to both unknown reward-noise and unknown environmental drift. The target is a mathematically precise open problem identified in the 19 October 2026 preprint:

> Xiaojin Zhang, *Variance-Aware Non-Stationary Bandits: All-Budget Regret Bounds and Adaptation Costs*, arXiv:2610.26116 (v1, 19 Oct 2026).

The paper characterizes the minimax rate when both budgets are supplied to the learner, and proves a sharp adaptation frontier on a disclosed deterministic one-improvement family. It explicitly leaves open a sharp prior-free schedule for the unrestricted noisy model. We will not relabel an existing theorem as a new result.

## Research question

In an oblivious stochastic multi-armed bandit with selected-arm feedback, can we characterize the best simultaneous guarantees of a *single policy* that knows the number of arms and horizon but is not given either:

- the cumulative variance envelope (Q), or
- the cumulative variation of the mean reward vector (B)?

The goal is to establish matching upper and lower bounds for the attainable adaptation profile, or prove that a stronger impossibility barrier prevents such matching.

Definitions, conventions, known results, and the exact scope are in [docs/RESEARCH_QUESTION.md](docs/RESEARCH_QUESTION.md). Prior-work exclusions are in [docs/RELATED_WORK.md](docs/RELATED_WORK.md).

## First verified milestone

`formal/AdaptationFrontier.lean` formalizes an algebraic corollary of Theorem 5.1 of arXiv:2610.26116. Under the theorem's two regret inequalities and the paper's scale assumptions, it proves the explicit lower bound (r_1 \geq gu/12), where (u^2=nq), (u\geq4), and (n\leq u).

**Important limitation:** this Lean theorem formalizes the algebraic deduction from the paper's Theorem 5.1. It does *not* formalize the stochastic bandit model, the information-theoretic proof of Theorem 5.1, or a new solution to the unrestricted noisy adaptation problem.

## Repository map

- `formal/AdaptationFrontier.lean` — Lean proof of the first algebraic corollary.
- `docs/RESEARCH_QUESTION.md` — definitions, target theorem, scope, and non-goals.
- `docs/RELATED_WORK.md` — literature audit and novelty guardrails.
- `docs/RESEARCH_ROADMAP.md` — phased work plan and acceptance criteria.
- `docs/TOOL_ROLES.md` — roles and limits of the connected open-source tools.
- `.github/workflows/lean.yml` — Lean build on pushes and pull requests.

## Verification

The formal project is pinned to Lean `v4.36.0-rc2` and Mathlib tag `v4.36.0-rc2`. Run:

```sh
lake exe cache get
lake build
```

The CI build is the authoritative execution check. A written proof, a symbolic calculation, a solver result, or an AI explanation is not counted as Lean-verified until the CI job succeeds.

## Evidence policy

- **PROVED:** kernel-checked Lean theorem, with the exact file and CI run linked.
- **REPRODUCED:** independently reproduced computation or published result, with scripts and assumptions.
- **CONJECTURE:** a candidate statement not yet proved.
- **OPEN:** a precise target with no accepted proof in this repository.
- **BLOCKED:** missing prerequisites or failed verification.

No `sorry`, `admit`, fabricated experiment, unverified CI pass, or paid service is permitted. An incomplete theorem remains incomplete.

## Project title and repository name

The project title is now set in this README. The connected GitHub actions available in this session can create branches, files, commits, issues, and pull requests, but do not expose the repository-rename endpoint. Therefore the GitHub repository slug remains `2503140kcsk-eng/A` until it is renamed through GitHub's repository settings.

## Primary source

- https://arxiv.org/abs/2610.26116
- https://arxiv.org/html/2610.26116v1
