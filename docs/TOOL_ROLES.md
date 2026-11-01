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


## Execution record — 1 November 2026, resumed pass

| Component | Actually exercised in this pass | Evidence boundary |
|---|---|---|
| GitHub connector | Read PR #2 and branch sources; archived the failed measure-KL attempt; reworked and verified the finite-history sequential KL chain rule; added it to the root import graph; updated README, progress, and research documentation. | Mutations are visible in branch commits; the PR remains Draft. |
| GitHub Actions / Lean | Pinned Lean v4.36.0-rc2 / Mathlib v4.36.0-rc2 build with `--wfail`. The first sequential-history draft failed on a type-reduction issue; a second recursive-measurable-space formulation passed, and the verified module is imported from the root. The measure-level KL bridge remains archived. | Runs 41300592276 and 41300588286 both passed exact finite checks and Lean build on source commit 8e7ae0dc10024ac0b7289dd397ea0a1a27324a37. |
| Mathlib4 | Used pinned PMF, integral, measure, Markov-kernel, and KL chain-rule APIs; inspected exact pinned source for `PMF.toMeasure`, `klDiv_compProd_eq_add`, and common-kernel cancellation. | Four compiled modules contain the verified declarations. The PMF-to-measure KL bridge remains unverified. |
| Context7 | Resolved Mathlib4 and queried finite PMF integration, `PMF.toMeasure`, `rnDeriv`, `withDensity`, and KL APIs. | Context7's retrieved examples include current `master`; version-sensitive names were cross-checked against the exact pinned v4.36.0-rc2 source. |
| Wolfram | Evaluated exact point-spike and separated-signal means, variances, and forward KL expressions. | It checked supplied algebra: point-spike mean `5/8`, variance `3/32 + 3 s^2/5`, KL `log(5/3)`; separated-signal mean `5/8`, variance `11/224 + 3 s^2/7`, KL `log(7/3)`. It does not prove the probability or adaptation arguments. |
| Parallel Search | Retrieved the 19 October 2026 arXiv paper's primary HTML and searched for prior work on variation budgets, bandit adaptation, and change detection. | Source discovery and theorem-scope comparison only. |
| Sider Scholar | Retrieved the exact arXiv:2610.26116v1 record and queried related nonstationary-bandit literature. | The results are not an exhaustive novelty review. The result viewer was exposed by the Scholar search response. |
| Python standard library | The repository CI runs `scripts/independent_checks.py`: 200 randomized nonanticipating history-dependent policy kernels; 53,516 baseline transcripts; 2,046 pull-time subsets; and 13,231 exact rational `(T,tau)` budget pairs. | Finite regression checks only, not a universal theorem. The authoritative reproducible status is the GitHub Actions run. |

## Upstream repository roles and actual execution boundaries

| Repository | Assigned role in this project | Executed as a standalone solver in this pass? |
|---|---|---|
| `leanprover-community/mathlib4` | Primary Lean mathematics: finite PMFs, measures, KL divergence, kernels, and real-analysis lemmas. | **Yes**, through pinned Lean/Mathlib CI and direct source inspection. |
| `lean-dojo/LeanDojo-v2` | Retrieve declarations, theorem premises, and search for formalization patterns; use it to propose proof routes, never as a proof checker. | **No**. |
| `cvc5/cvc5` | SMT counterexample search for finite rational/real constraints, rate inequalities, and candidate encodings; keep logic/options/certificates. | **No**. |
| `sympy/sympy` | Exact rational simplification and factorization. | **No**. The checked script uses Python `Fraction`; Wolfram handled the symbolic identities. |
| `sagemath/sage` | Exact LP and small rational zero-sum game enumeration for finite-horizon policy relaxations. | **No**. |
| `gap-system/gap` | Symmetry groups and orbit reduction for arm-permutation-equivalent finite environments. | **No**. |
| `Macaulay2/M2` | Optional elimination/commutative algebra if a polynomial-ideal reduction appears; not needed for this finite probability calculation. | **No**. |
| `naproche/naproche` | Independent checking of isolated prose/classical arguments; its result would not replace Lean. | **No**. |

No paid API, paid hosted notebook, commercial solver, paid compute, or deployment was used. GitHub Actions account quota/remaining minutes were not observable. The upstream repositories are references/dependencies; no changes were written to them.

## Current acceptance boundary

- The compiled Lean library imports `AdaptationFrontier.lean`, `PositiveNoiseAdaptation.lean`, `PositiveNoisePMF.lean`, and `SequentialKL.lean` through `BudgetFreeBandits.lean`.
- `SequentialKL.lean` kernel-checks the generic finite-horizon adaptive KL chain rule for recursive complete histories and arbitrary Markov transition kernels.
- `PositiveNoiseMeasureKL.lean` remains archived as `docs/drafts/PositiveNoiseMeasureKL.lean.md`; it has not yet connected the finite discrete KL to Mathlib's measure-level KL.
- The concrete point-spike specialization of the all-history KL identity, path-counting lower proof, policy expected-regret proof, and final restricted ratio comparison remain written arguments rather than end-to-end kernel-checked theorems.
- The PR must remain Draft until those remaining probability/regret arguments are formalized and independently reviewed for novelty.

## Additional formalization completed — finite-horizon adaptive KL

`BudgetFreeBandits/SequentialKL.lean` is now part of the compiled root library. It defines the complete history recursively and makes the history measurable spaces explicit, so the composition-product history type is definitionally the next-round history type. It proves:
- every transcript generated by a sequence of Markov kernels is a probability measure;
- the conditional one-round KL cost at time t, evaluated under the baseline history law;
- the finite-horizon identity expressing full transcript KL as the finite sum of those local conditional KL costs.

The proof is checked by Lean's kernel under pinned Mathlib and uses `InformationTheory.klDiv_compProd_eq_add`. The transition kernels may depend on the entire previous history. The earlier failed source attempt is preserved as an archived draft but has been superseded by this verified module.