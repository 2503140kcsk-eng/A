# Positive-noise two-budget adaptation theorem

**Status:** theorem for an explicitly disclosed finite family; unrestricted model remains open.  
**Novelty:** provisional; independent review remains necessary.  
**Date:** 1 November 2026.

This note supersedes the earlier Bernoulli-only KL candidate as the main positive-noise adaptation construction. Both the stationary baseline and every changing alternative have strictly positive reward variance at every arm and round. The two environment classes have different, strictly positive variance budgets.

## 1. Finite family

Fix integers \(A,T\) with \(A\ge 2\) and \(T\ge 32A\). Put \(n=A-1\), \(K=\lfloor T/2\rfloor\), and \(q=K-1\). Let
\[
g=\frac18,\qquad \varepsilon=\frac25,\qquad
s_T=\frac{1}{64\sqrt T},\qquad s_T^2=\frac{1}{4096T}.
\]

Let \(P_T\) assign probability \(1/2\) to each of \(3/8-s_T\) and \(3/8+s_T\). Let \(C_T\) assign probability \(1/2\) to each of \(1/2-s_T\) and \(1/2+s_T\).

The stationary baseline \(\nu^0\) uses \(C_T\) on arm 1 and \(P_T\) on every challenger, at every round.

For each challenger \(a\in\{2,\ldots,A\}\) and each change time \(\tau\in\{2,\ldots,K\}\), the alternative \(\nu^{a,\tau}\) agrees with the baseline except that, from round \(\tau\) onward, the law of arm \(a\) becomes
\[
Q_T=(1-\varepsilon)P_T+\varepsilon\delta_1.
\]

The learner knows the family and its constants \(A,T,g,\varepsilon,s_T\), but is not told whether a change occurs, which arm changes, or when. It uses one fixed nonanticipating randomized policy. Rewards are independent across rounds, and the environment is fixed before interaction.

All points in the support of \(P_T,C_T\) are strictly below 1. Therefore, observing reward 1 on a challenger is an unambiguous certificate that it is the changed arm.

## 2. Moments, budgets, and one-step KL

The baseline means are
\[
\mu_1=\frac12,\qquad \mu_a=\frac38=\frac12-g\quad(a\ge2).
\]
The changed arm's new mean is
\[
(1-\varepsilon)\frac38+\varepsilon=\frac58=\frac12+g.
\]
Thus every alternative has exactly one consecutive mean change, of size
\[
B=\frac58-\frac38=\frac14.
\]

The baseline variance of every arm is \(s_T^2=1/(4096T)>0\), so its variance budget is exactly
\[
Q_0=T s_T^2=\frac1{4096}>0.
\]

The variance of the spike mixture is
\[
v_T=(1-\varepsilon)s_T^2+
\varepsilon(1-\varepsilon)\left(1-\frac38\right)^2
=\frac3{32}+\frac35s_T^2.
\]
For an alternative changing at \(\tau\), the variance envelope is
\[
Q_{a,\tau}=(\tau-1)s_T^2+(T-\tau+1)v_T.
\]
Since \(\tau\le T/2\) and \(T\ge32A\ge64\),
\[
\boxed{\frac{3T}{64}\le Q_{a,\tau}\le\frac T8.}
\]
The two classes therefore have genuinely different positive-noise budgets:
\[
(Q_0,B_0)=\left(\frac1{4096},0\right),\qquad
Q_{a,\tau}\in\left[\frac{3T}{64},\frac T8\right],\quad B_{a,\tau}=\frac14.
\]

On each of the two baseline support points, the alternative assigns probability \((1-\varepsilon)/2=3/10\), whereas the baseline assigns probability \(1/2\). The remaining mass \(2/5\) is placed at 1. Hence the exact one-observation divergence, in the baseline-to-alternative direction, is
\[
\boxed{
D_{\mathrm{KL}}(P_T\Vert Q_T)
=\frac12\log\frac{1/2}{3/10}
 +\frac12\log\frac{1/2}{3/10}
=\log\frac53.
}
\]
The reverse divergence is infinite because \(Q_T\) has an atom at 1 outside the support of \(P_T\). The direction displayed above is the one needed for the adaptive transcript chain rule.

## 3. Adaptive KL chain rule

Let \(\mu_t,\nu_t\) be the baseline and alternative history laws before round \(t\), and let \(\pi_t\) be the learner's common action kernel from history to arms. The action kernel is identical under both environments conditional on every shared history.

Mathlib 4.36.0-rc2 contains the theorem InformationTheory.klDiv_compProd_left, which states
\[
D_{\rm KL}(\mu_t\otimes\pi_t\Vert\nu_t\otimes\pi_t)
=D_{\rm KL}(\mu_t\Vert\nu_t).
\]
It also contains InformationTheory.klDiv_compProd_eq_add:
\[
D_{\rm KL}(\mu\otimes\kappa\Vert\nu\otimes\eta)
=D_{\rm KL}(\mu\Vert\nu)
 +D_{\rm KL}(\mu\otimes\kappa\Vert\mu\otimes\eta).
\]
Apply the first identity to the action stage and the second to the selected-reward stage, round by round. Conditional reward laws differ only when the selected arm is \(a\) and \(t\ge\tau\). In that case the KL contribution is exactly \(\log(5/3)\); otherwise it is zero. Iterating the finite-horizon recursion yields
\[
\boxed{
D_{\rm KL}(\mathbb P_0^T\Vert\mathbb P_{a,\tau}^T)
=\log(5/3)\,\mathbb E_0[N_a(\tau,T)].
}
\]
This is the rigorous cancellation mechanism for adaptive action selection. The added Lean module formalizes the Mathlib action-kernel cancellation and the two-stage chain-rule adapter, as well as the exact scalar mean, variance, and KL identities. The induction over the full finite history process is described here but is **not** marked kernel-checked until the finite-history model is separately added.

There is also a useful coupling. Generate a baseline reward \(Y\sim P_T\) and an independent Bernoulli mark \(Z\sim\mathrm{Ber}(\varepsilon)\). Under the alternative, return \(Y\) if \(Z=0\), and 1 if \(Z=1\). Until the first marked pull of the changed arm, the complete observable histories can be coupled identically. In particular, an unmarked pull of the changed arm does not reveal the change.

## 4. Positive-noise lower frontier

For a policy \(\pi\), let
\[
r_0=\mathbb E_0[R_T],\qquad
r_1=\max_{a\ge2,\;2\le\tau\le K}\mathbb E_{a,\tau}[R_T].
\]
Then, with \(q=K-1\), every nonanticipating randomized policy satisfies
\[
\boxed{
r_0\le\frac{gnq}{2}
\quad\Longrightarrow\quad
r_1\ge\frac{g^2nq}{8(r_0+gn)}.
}
\tag{PN-LB}
\]

**Proof.** Work under the baseline trajectory. For a fixed challenger \(a\), list its pull times in rounds \(2,\ldots,K\):
\[
p_1<\cdots<p_m.
\]
Add sentinels \(p_0=1\), \(p_{m+1}=K+1\), and define gap lengths
\[
L_j=p_{j+1}-p_j-1\quad(0\le j\le m).
\]
Then \(\sum_jL_j=q-m\). For any change time \(\tau\) in the open gap \((p_j,p_{j+1})\), no pull of \(a\) occurs from \(\tau\) through \(p_{j+1}-1\). Couple the alternative with the baseline until its first marked pull of \(a\). All actions during this gap are therefore identical to the baseline actions and choose an arm other than \(a\), so each incurs at least \(g\) pseudo-regret in the alternative. Summing over change times in the gap gives
\[
g\frac{L_j(L_j+1)}2\ge\frac g2L_j^2.
\]
Thus, pathwise,
\[
\sum_{\tau=2}^{K}
\text{(alternative regret before its first post-change pull of \(a\))}
\ge\frac g2\sum_{j=0}^{m}L_j^2
\ge\frac g2\frac{(q-m)^2}{m+1},
\]
where the last step is Cauchy–Schwarz.

Under the baseline, every challenger pull incurs regret \(g\). If \(M_a\) counts pulls of \(a\) in rounds \(2,\ldots,K\), then
\[
\frac1n\sum_{a=2}^{A}\mathbb E_0[M_a]
\le\frac{r_0}{gn}.
\]
The function
\[
f(x)=\frac{(q-x)^2}{x+1}
=\frac{(q+1)^2}{x+1}-2(q+1)+(x+1)
\]
is convex and decreasing on \([0,q]\), since \(f''(x)=2(q+1)^2/(x+1)^3>0\) and \(f'(x)=1-(q+1)^2/(x+1)^2\le0\). Jensen's inequality and \(r_0/(gn)\le q/2\) imply
\[
r_1\ge\frac{g}{2q}f\!\left(\frac{r_0}{gn}\right)
\ge\frac{gq}{8(r_0/(gn)+1)}
=\frac{g^2nq}{8(r_0+gn)}.
\]
This extends the deterministic one-improvement gap-counting lower bound to a family in which both the baseline and the changing alternatives have strictly positive variance. \(\square\)

## 5. Budget-unaware upper algorithm

For this disclosed family, the following single policy uses \(A,T\) and the family constants, but does **not** use \(Q\) or \(B\).

Set
\[
p=\left(\frac AT\right)^{5/6}.
\]
Until a reward of 1 is observed, independently each round:
- with probability \(p\), choose a uniformly random challenger;
- with probability \(1-p\), choose arm 1.

After observing reward 1 on a challenger, play that challenger for the rest of the horizon.

There are no false alarms under the baseline because every baseline support point is below 1. Hence
\[
\mathbb E_0[R_T]=gpT.
\]
Under any alternative, while the change is undetected, the probability of observing the atom 1 in a given round is exactly \(p\varepsilon/n\). The detection time after \(\tau\) is geometric with mean \(n/(p\varepsilon)\). Before detection, every round's regret is at most \(2g\); after detection it is zero. Therefore
\[
\boxed{
\mathbb E_{a,\tau}[R_T]
\le2g\min\left\{T,\frac{n}{p\varepsilon}\right\}
\le\frac{2gn}{p\varepsilon}.
}
\tag{PN-UB}
\]

For the supplied-budget oracle benchmark
\[
\Xi(A,T;Q,B)=
\min\left\{T,\,
A+\sqrt{AQ}+(AQBT)^{1/3}
+\sqrt{AT}\min\{B,\sqrt B\}\right\},
\]
the baseline satisfies
\[
A\le\Xi(A,T;Q_0,0)\le2A.
\]
For every alternative, \(3T/64\le Q\le T/8\) and \(B=1/4\). Set
\[
c_0=\left(\frac3{256}\right)^{1/3},\qquad U=(AT^2)^{1/3}.
\]
Then
\[
c_0U\le\Xi(A,T;Q,1/4)\le4U.
\]
Combining these inequalities with \(p=(A/T)^{5/6}\), \(n\le A\), \(g=1/8\), and \(\varepsilon=2/5\) gives
\[
\boxed{
\sup_{\nu\in\mathcal F}
\frac{\mathbb E_\nu[R_T]}{\Xi(A,T;Q(\nu),B(\nu))}
\le4\left(\frac TA\right)^{1/6}.
}
\tag{PN-UPPER}
\]

## 6. Matching oracle-competitive lower bound

Define the restricted-family competitive ratio
\[
\mathfrak C(\pi;A,T)=
\sup_{\nu\in\mathcal F}
\frac{\mathbb E_\nu[R_T]}{\Xi(A,T;Q(\nu),B(\nu))},
\]
where \(\mathcal F\) consists of the baseline and all alternatives with \(2\le\tau\le K\). Let \(C=\mathfrak C(\pi;A,T)\). The oracle estimates imply
\[
r_0\le2AC,\qquad r_1\le4CA^{1/3}T^{2/3}.
\]

If \(r_0\ge gnq/2\), then \(C\ge r_0/(2A)\ge T/192\). Otherwise (PN-LB), \(q\ge T/3\), and \(n\ge A/2\) give
\[
\frac{T}{6144(C+1)}
\le r_1
\le4CA^{1/3}T^{2/3}.
\]
Consequently
\[
C(C+1)\ge\frac1{24576}\left(\frac TA\right)^{1/3},
\]
and in either case
\[
\boxed{
\mathfrak C(\pi;A,T)\ge
\frac1{49152}\left(\frac TA\right)^{1/6}.
}
\tag{PN-LOWER}
\]

Together with (PN-UPPER), this proves the optimal restricted-family order
\[
\boxed{
\inf_{\pi\text{ not told }Q,B}\mathfrak C(\pi;A,T)
=\Theta\!\left((T/A)^{1/6}\right).
}
\]
The policy is budget-unaware; the lower bound quantifies the cost of serving the low-\(Q\), stationary class and the high-\(Q\), changing class with the same policy.

## 7. Scope and remaining open work

**Established for this explicitly disclosed family:**
- all arms and all rounds have strictly positive reward variance;
- the stationary and changing classes have distinct positive variance budgets, \(Q_0=1/4096\) and \(Q=\Theta(T)\);
- mean variation changes from \(B=0\) to \(B=1/4\);
- the one-step KL contribution is exactly \(\log(5/3)\);
- action-kernel cancellation and the generic two-stage KL chain rule are available in pinned Mathlib;
- the gap-counting lower bound and a matching budget-unaware probe-and-commit policy give a \(\Theta((T/A)^{1/6})\) restricted-family oracle-competitive ratio.

**Not established:**
- the Pareto frontier for all bounded stochastic selected-arm environments;
- a prior-free algorithm attaining the optimal profile for every admissible pair \((Q,B)\);
- a matching upper bound for the unrestricted noisy model;
- a general novelty claim.

This is a positive-noise obstruction and matching algorithm for a carefully disclosed two-class subproblem, **not** a solution of the unrestricted Section 6 open problem in arXiv:2610.26116v1. PR #2 must remain draft until the finite-history induction, gap-sum lemma, ratio algebra, pinned Lean CI, and independent novelty review are complete.

## 8. Tool/repository roles

- **Mathlib4, pinned v4.36.0-rc2:** kernel KL chain rule, measure theory, finite sums, and formal proof.
- **LeanDojo-v2:** retrieve declarations and theorem premises; generated tactic suggestions are not proof evidence.
- **cvc5:** search finite counterexamples to gap-counting and rate inequalities; retain logic, options, and certificates.
- **SymPy:** exact rational simplification of moments, budgets, and constants.
- **SageMath:** finite policy-tree enumeration and LP cross-checks for small \(A,T\).
- **GAP:** arm-permutation orbit reductions for finite policy/environment trees.
- **Naproche:** independent prose-proof checking, not a replacement for Lean.
- **Macaulay2:** no current role; activate only if a later polynomial-ideal reduction arises.

Upstream repositories are read-only references. Their outputs are not treated as proofs unless independently derived or checked in Lean. No paid model API, paid compute, or paid hosted service is required.
