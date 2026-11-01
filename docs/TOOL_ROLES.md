# Tool roles, boundaries, and reproducibility

This project uses free/open-source mathematical tools where they genuinely help. Tool outputs are aids to proof discovery; none is accepted as a theorem without a sound proof or independently checked derivation.

## Research and documentation tools

| Tool | Assigned role | What it cannot establish |
|---|---|---|
| Sider Scholar | Discover papers, retrieve open-access work, compare cited literature, maintain a traceable reading collection. | Search ranking or an abstract cannot certify novelty or correctness. |
| Parallel Search | Search primary papers, revisions, supplementary files, and software documentation; cross-check exact claims. | Search excerpts are not a substitute for exact theorem assumptions. |
| Wolfram | Exact symbolic/algebraic sanity checks and finite numerical examples. | Symbolic output is not a proof of a probabilistic bandit theorem. |
| Context7 | Verify current Lean/Mathlib and symbolic-computation APIs before writing code. | Documentation does not prove project code compiles. |
| GitHub | Canonical source, issues, commits, CI status, formal proofs, and reproducible experiments. | A commit does not mean CI passed or a claim is true. |

## Open-source repository roles

### Primary proof and model

- **mathlib4:** formal mathematics library. Use measure theory, conditional expectation, filtration, martingales, finite sums, and real analysis.
- **LeanDojo-v2:** inspect/traverse Lean source, retrieve declarations, and experiment with theorem-premise search. Use local/open tooling only; hosted inference is not assumed free or available.

### Independent mathematical and solver checks

- **cvc5:** SMT checks for finite rational/real constraints, consistency of finite relaxations, and counterexample search. Solver sat/unsat results must retain logic, options, and proof/certificate status; they do not replace Lean.
- **SymPy:** exact rational simplification, symbolic factorization, and checking algebraic implications among rate expressions.
- **SageMath:** exact linear programming and rational zero-sum matrix-game experiments for finite-horizon toy models.
- **GAP:** symmetry groups and orbit reductions for finite environment families where arm relabeling creates genuine equivalence classes.
- **Macaulay2:** optional commutative-algebra support if a later lower-bound reduction yields polynomial ideals or elimination problems. It is not a core dependency for the initial bandit theorem.
- **Naproche:** independent natural-language mathematical-document checking for isolated classical arguments. Accepted prose is not equivalent to a Lean kernel proof.

## Use order for a new claim

1. State model and theorem in RESEARCH_QUESTION.md.
2. Search prior work and record near matches in RELATED_WORK.md.
3. Derive the argument and test small cases exactly with SymPy/Sage/Wolfram.
4. Use cvc5 to search finite counterexamples or validate finite constraint encodings.
5. If finite symmetry exists, use GAP to reduce equivalent cases.
6. Formalize the central theorem in Lean/Mathlib.
7. Use LeanDojo-v2 for source retrieval/proof-premise exploration, not as an authority.
8. Optionally express the prose proof in Naproche.
9. Commit source and require the pinned GitHub Actions build to pass.

## Free-use policy

The plan assumes no paid model APIs, paid computation, paid storage, or proprietary solver; no paid hosted Sage/notebook requirement; reproducible local or free CI execution; and pinned versions where feasible.

The upstream repositories are dependencies or reference tools only. This project has no write permission to those upstream repositories; project code and proof artifacts are committed to 2503140kcsk-eng/A.


## Execution record for the 1 November 2026 research pass

The following roles were actually exercised in this pass:

| Component | Actual use in this pass | Evidence / limit |
|---|---|---|
| GitHub connector | Read PR #2, repository source, pinned toolchain, prior CI, and committed the new PMF source plus research note. | Commits and Actions run URLs are recorded in the conversation and repository history. |
| GitHub Actions / Lean | Attempted the pinned Lean v4.36.0-rc2 build with --wfail; initial PMF implementation exposed syntax and ENNReal normalization errors and is being iteratively repaired. | A failed build is not a proof pass. The new PMF module must not be described as verified until a later head commit passes. |
| Context7 | Resolved the Mathlib library and queried finite PMF construction / expectation APIs. | API discovery only. The pinned source at v4.36.0-rc2 was also read directly. |
| Sider Scholar | Searched prior variance-adaptive bandit and change-detection literature. | Search result quality was mixed; no novelty conclusion is inferred from ranking alone. |
| Parallel Search | Cross-checked arXiv and primary conference sources, including bandit quickest changepoint detection. | Related work confirms adaptive sensing/detection is known; it does not settle this exact restricted regret ratio. |
| Wolfram | Recomputed exact means, variances, KL and searched for violations of the original variance-budget bounds. | Symbolic checks are independent sanity checks, not formal proofs. |
| Python / SymPy | Exact-rational sweeps for the non-degenerate separated-signal variance budgets; enumerated randomized finite-history policies for horizons 1–5 and checked the transcript likelihood-ratio/count identity. | The transcript experiment covered 200 randomly generated history-dependent policy kernels; it is not a universal theorem. |

The following requested repositories were assigned roles but their standalone executables were **not available in the execution environment**, so no run is claimed:

- SageMath: exact LP and finite policy-game enumeration.
- cvc5: SMT search over finite rational counterexamples.
- GAP: arm-symmetry group/orbit reduction.
- Macaulay2: not needed for the present finite probability / information-theory argument; reserve it for a later algebraic-geometry reduction.
- LeanDojo-v2: theorem/source retrieval and proof-premise exploration only; not used as a proof checker here.
- Naproche: independent prose-proof checking; not run.

No paid API, paid notebook, hosted proprietary solver, deployment, or external project write was used. A user-specific GitHub Actions quota/billing allowance was not observable here; users should check their account's current Actions allowance before relying on repeated CI runs.
