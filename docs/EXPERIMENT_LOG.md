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


## Check 3 — positive-noise spike family: exact moments and KL

For the two-point baseline law \(P_T\) with support \(3/8\pm s_T\), \(s_T^2=1/(4096T)\), and its alternative \(Q_T=(3/5)P_T+(2/5)\delta_1\), exact Wolfram simplification returned:
\[
\mathbb E_{Q_T}[X]=\frac58,\qquad
\operatorname{Var}(Q_T)=\frac3{32}+\frac3{5}s_T^2,
\]
and
\[
D_{\rm KL}(P_T\Vert Q_T)=\log\frac53.
\]
The baseline variance budget is \(Q_0=1/4096>0\). For \(2\le\tau\le T/2\), the alternative budget is
\[
Q_{a,\tau}=(\tau-1)s_T^2+(T-\tau+1)\left(\frac3{32}+\frac3{5}s_T^2\right).
\]

Wolfram Reduce was run on the two putative counterexample conditions \(Q_{a,\tau}<3T/64\) and \(Q_{a,\tau}>T/8\), under \(T\ge64\) and \(2\le\tau\le T/2\). Both outputs were False. Thus the symbolic checks found no counterexample to
\[
\frac{3T}{64}\le Q_{a,\tau}\le\frac T8.
\]

## Check 4 — gap-counting function

For \(f(x)=(q-x)^2/(x+1)\), Wolfram returned
\[
f''(x)=\frac{2(1+q)^2}{(1+x)^3},\qquad
f'(x)=-\frac{(q-x)(2+q+x)}{(1+x)^2}.
\]
Consequently \(f\) is convex and nonincreasing on \(0\le x\le q\), the two properties used in the Jensen step of the positive-noise lower-bound proof.

**Evidence limit:** these symbolic checks verify the displayed scalar expressions and inequalities only. They do not verify the coupling argument, the pathwise gap count, the adaptive finite-history KL induction, the algorithm's regret analysis, or novelty. Those mathematical steps are documented separately and retain their own proof/verification status.


## Check 5 — non-degenerate separated-signal extension

For baseline \(P_T\) on \(3/8\pm s_T\), signal law \(R\) on \(\{3/4,7/8\}\) with equal mass, and
\[
\widetilde Q_T=\frac37P_T+\frac47R,
\]
Wolfram simplification gives
\[
\mathbb E_{\widetilde Q_T}[X]=\frac58,\qquad
\operatorname{Var}(\widetilde Q_T)=\frac{11}{224}+\frac37s_T^2.
\]
The exactly separated signal event \(S=\{3/4,7/8\}\) has probability \(4/7\) after the change and zero before the change. Therefore
\[
D_{\rm KL}(P_T\Vert\widetilde Q_T)=\log(7/3).
\]
This removes the deterministic marker while retaining a perfectly observable signal event. It does not remove the support-separation assumption.

## Check 6 — exact independent finite regression checks

The repository script scripts/independent_checks.py uses only Python's standard library and fractions.Fraction:

- 200 randomly generated nonanticipating action kernels depending on complete histories, with horizons 1–5; for every baseline transcript, the exact likelihood ratio equalled \((5/3)^{N_a}\).
- 2,046 pull-time subsets for the gap-counting and Cauchy–Schwarz inequalities with \(q\le10\).
- 13,231 exact rational \((T,\tau)\) pairs checking the point-spike and separated-signal variance-budget envelopes, for \(64\le T\le240\).

The local run passed. The same command is now placed before the Lean build in .github/workflows/lean.yml; the Actions result is the reproducible CI check. These finite tests are regression checks only, not proofs for all policies or horizons.
