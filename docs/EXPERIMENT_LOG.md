# Exact symbolic sanity checks

**Date:** 1 November 2026  
**Tool:** Wolfram Language evaluator  
**Purpose:** independently check algebraic side conditions in the candidate lower-bound derivation. These checks are not proofs of the probabilistic KL argument.

## Check 1 — published-frontier denominator estimate

Input:
```wl
Reduce[
  ForAll[{g,n,u,r0},
    g > 0 && n > 0 && u >= 4 && n <= u &&
    r0 >= 0 && r0 < g*u/2,
    8*(r0 + g*n) <= 12*g*u
  ],
  Reals
]
```

Observed output: `True`.

Interpretation: under the explicit assumptions, the denominator estimate used in the Lean corollary of the published Theorem 5.1 inequalities holds.

## Check 2 — Bernoulli KL upper bound

For
[
d_g=2g\log\left(\frac{1/2+g}{1/2-g}\right),
]
the claimed bound (d_g\leq 32g^2/3) is equivalent to
[
3\log\left(\frac{1+2g}{1-2g}\right)\leq16g.
]

Input:
```wl
Reduce[
  0 < g <= 1/4 &&
  3 Log[(1 + 2 g)/(1 - 2 g)] > 16 g,
  g, Reals
]
```

Observed output: `False`.

Interpretation: the symbolic solver found no counterexample in the claimed interval (0<g\leq1/4). This is a computational sanity check of the logarithmic inequality only; the candidate KL/Pinsker lower bound remains unproved and not novelty-checked.

## Evidence boundary

- A symbolic `True` / `False` result checks the formula supplied to the evaluator.
- It does not validate the stochastic model, the chain rule for adaptive transcript KL, Pinsker's application, or the main prior-free adaptation objective.
- The published-theorem algebra is separately verified by Lean CI; see the run recorded in `docs/PROGRESS_LOG.md`.
