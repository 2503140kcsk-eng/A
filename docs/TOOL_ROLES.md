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

| Component | Actually exercised | Evidence boundary |
|---|---|---|
| GitHub connector | Re-read PR #2, all core Lean files, project workflow, and research notes; committed PMF, measure-KL bridge draft, exact-check script, and workflow changes. | Git commits and Actions runs are visible in the branch history. |
| GitHub Actions / Lean | Verified the PMF module in earlier pinned v4.36.0-rc2 --wfail runs. The newer measure-level KL bridge is being built separately; it is not called verified until its current workflow passes. | See the live Actions run linked from PR #2. |
| Context7 | Resolved Mathlib4 and queried the finite-PMF integration API. | API discovery only; the exact pinned Mathlib source was also inspected. |
| Wolfram | Evaluated exact mean, variance and KL expressions for the point-spike family; also checked variance-envelope bounds symbolically. | Symbolic checks validate the supplied algebra, not the bandit probability proof. |
| Python standard library | Ran exact-rational budget sweeps; enumerated 200 history-adaptive randomized policy kernels for horizons 1–5; checked 53,516 baseline transcripts; exhaustively checked 2,046 pull subsets for gap-counting with q <= 10. | This is a finite independent regression test, not a universal theorem. Reproduction: python3 scripts/independent_checks.py. |
| Parallel Search | Retrieved primary-source abstracts for the 19 October 2026 paper and established change-detection / variation-adaptation prior work. | Literature discovery, not proof verification. |
| Sider Scholar | Retrieved the exact arXiv record/abstract for arXiv:2610.26116 and searched related nonstationary-bandit work. | The search is not an exhaustive novelty proof. |

The following user-supplied repositories have **assigned roles but were not executed as standalone tools in this environment**:

- **SymPy:** exact symbolic simplification; not run in this pass (the reproducible checker uses Python Fraction instead).
- **SageMath:** exact LP and finite policy-game enumeration; not run.
- **cvc5:** SMT counterexample search; not run.
- **GAP:** arm-symmetry/orbit reduction; not run.
- **Macaulay2:** algebraic-geometric elimination if a polynomial-ideal reduction appears; not needed for the present finite probability construction and not run.
- **LeanDojo-v2:** theorem/source retrieval and premise search; not run as a proof checker.
- **Naproche:** prose-proof checking; not run.
- **Mathlib4:** used through pinned Lean CI and direct source inspection.

No paid API, hosted Sage notebook, commercial solver, paid compute, or deployment was used. GitHub Actions account quota/remaining minutes were not observable; the workflow uses the repository's standard hosted CI.
