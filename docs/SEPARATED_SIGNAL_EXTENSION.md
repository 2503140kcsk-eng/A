# Non-degenerate separated-signal extension

**Status:** complete mathematical derivation for a second disclosed finite family; Lean formalization pending.  
**Purpose:** remove the deterministic reward-1 atom from the positive-noise construction without pretending to solve the unrestricted model.  
**Date:** 1 November 2026.

## 1. New construction

Fix integers \(A\ge 2\), \(T\ge 32A\), and put
\[
n=A-1,\quad K=\lfloor T/2\rfloor,\quad q=K-1,\quad
g=\frac18,\quad s_T^2=\frac1{4096T}.
\]
Write \(s_T=1/(64\sqrt T)\).

Let the baseline challenger law \(P_T\) put mass \(1/2\) on each of
\[
\frac38-s_T,\qquad \frac38+s_T.
\]
Let the signal law \(R\), independent of \(T\), put mass \(1/2\) on each of
\[
\frac34,\qquad \frac78.
\]
Thus
\[
\mathbb E P_T=\frac38,\quad \operatorname{Var}(P_T)=s_T^2,
\qquad
\mathbb E R=\frac{13}{16},\quad \operatorname{Var}(R)=\frac1{256}.
\]
Set
\[
\varepsilon=\frac47,\qquad
\widetilde Q_T=(1-\varepsilon)P_T+\varepsilon R
=\frac37P_T+\frac47R.
\]

The baseline environment uses the two-point law on
\(1/2\pm s_T\) on arm 1 and \(P_T\) on every challenger. For every challenger \(a\in\{2,\ldots,A\}\) and change time \(\tau\in\{2,\ldots,K\}\), the alternative changes only arm \(a\), replacing \(P_T\) by \(\widetilde Q_T\) from round \(\tau\) onward.

Since \(T\ge64\), \(s_T\le1/512\), so the baseline support is contained in \([3/8-1/512,3/8+1/512]\), strictly below the signal support \(\{3/4,7/8\}\). The two supports are disjoint and are separated by a known gap. Both the baseline law and the signal law are non-degenerate; in particular, there is no deterministic reward atom.

## 2. Exact moments and budgets

The alternative mean is
\[
\mathbb E\widetilde Q_T
=\frac37\frac38+\frac47\frac{13}{16}
=\frac58.
\]
Hence the challenger mean changes from \(3/8\) to \(5/8\), exactly as in the point-signal construction. The dynamic variation budget remains
\[
B_{a,\tau}=\frac14.
\]

The mixture variance identity gives
\[
\begin{aligned}
\operatorname{Var}(\widetilde Q_T)
&=\frac37\operatorname{Var}(P_T)
 +\frac47\operatorname{Var}(R)
 +\frac37\frac47(\mathbb E R-\mathbb E P_T)^2\\
&=\frac37s_T^2+\frac47\frac1{256}
 +\frac{12}{49}\left(\frac7{16}\right)^2\\
&=\boxed{\frac{11}{224}+\frac37s_T^2}.
\end{aligned}
\]
Every arm has positive variance on every round: the unchanged laws have variance \(s_T^2>0\), and the changed law has variance at least \(11/224>0\).

The stationary variance budget remains
\[
Q_0=T s_T^2=\frac1{4096}>0.
\]
For an alternative,
\[
Q_{a,\tau}=(\tau-1)s_T^2
 +(T-\tau+1)\left(\frac{11}{224}+\frac37s_T^2\right).
\]
For \(T\ge64\) and \(2\le\tau\le T/2\), the changed duration is at least \(T/2\). Since
\[
\frac{11}{224}>\frac1{32},\qquad
\frac{11}{224}+\frac37\frac1{4096T}<\frac1{16},
\]
and the pre-change variance is also below \(1/16\), we obtain
\[
\boxed{\frac{T}{64}\le Q_{a,\tau}\le\frac{T}{16}.}
\]
Thus the two environment classes still have distinct strictly positive variance budgets, one constant and the other of order \(T\).

## 3. Exact one-step KL and a perfect signal event

Let \(S=\{3/4,7/8\}\). Then \(P_T(S)=0\), \(R(S)=1\), and
\[
P_T(S)=0,\qquad \widetilde Q_T(S)=\frac47.
\]
Consequently, observing a reward in \(S\) is an unambiguous certificate of the changed component. Unlike the earlier construction, the certificate is not a single deterministic reward.

On the support of \(P_T\), the alternative mass is exactly \((3/7)P_T\). Therefore the baseline-to-alternative divergence is
\[
\begin{aligned}
D_{\rm KL}(P_T\Vert\widetilde Q_T)
&=\sum_{x:P_T(x)>0}P_T(x)
 \log\frac{P_T(x)}{(3/7)P_T(x)}\\
&=\boxed{\log\frac73}.
\end{aligned}
\]
The reverse divergence is infinite because \(\widetilde Q_T\) assigns positive mass to \(S\), to which \(P_T\) assigns zero mass. The forward direction displayed above is the one used in the adaptive transcript chain rule.

More generally, for any two probability laws \(P,R\) on a measurable reward space with a measurable separating event \(S\) satisfying \(P(S)=0\), \(R(S)=1\), and \(Q=(1-\varepsilon)P+\varepsilon R\), one has
\[
Q(S)=\varepsilon,\qquad
D_{\rm KL}(P\Vert Q)=-\log(1-\varepsilon).
\]
The identity follows because \(dQ/dP=1-\varepsilon\) on the support of \(P\). This is a support-separated contamination lemma, not a generic result for overlapping distributions.

## 4. Adaptive finite-horizon KL identity

Use the same nonanticipating policy under the baseline and every alternative. Conditional on a common history, its action kernel is identical in the two environments, so the action-selection stage contributes zero conditional KL. The reward stage contributes \(\log(7/3)\) exactly when the chosen arm is \(a\) and the round is at least \(\tau\); otherwise it contributes zero.

Iterating Mathlib's composition-product chain rule over the finite horizon gives
\[
\boxed{
D_{\rm KL}(\mathbb P_0^T\Vert\mathbb P_{a,\tau}^T)
=\log\frac73\;\mathbb E_0[N_a(\tau,T)].
}
\]
Here \(N_a(\tau,T)\) is the number of selections of arm \(a\) from \(\tau\) through \(T\), and \(\mathbb P^T\) is the law of the entire observed action/reward history. The one-round Mathlib adapters establish the local chain-rule step, and `BudgetFreeBandits/SequentialKL.lean` now kernel-checks the generic recursive finite-history KL chain rule. What remains unformalized for this separated-signal construction is its concrete joint-kernel instantiation and the reduction of each local KL to `log(7/3)` times the baseline probability of selecting the changed arm.

## 5. Coupling, gap counting, and the lower bound

For each post-change selection of arm \(a\), generate a fresh independent Bernoulli mark \(Z\) with parameter \(4/7\). If \(Z=0\), return the same \(P_T\)-draw as in the baseline coupling; if \(Z=1\), return an independent \(R\)-draw. The supports are disjoint, so the learner sees a mark if and only if \(Z=1\). Until the first marked pull of arm \(a\), the baseline and alternative observations and actions can be coupled identically.

Under a baseline sample path, list the pull times of a fixed challenger \(a\) in rounds \(2,\ldots,K\) as
\(p_1<\cdots<p_m\), and add sentinels \(p_0=1\), \(p_{m+1}=K+1\). Let
\[
L_j=p_{j+1}-p_j-1\quad(0\le j\le m).
\]
Then \(\sum_j L_j=q-m\). For every change time in the open gap \((p_j,p_{j+1})\), no pull of \(a\) occurs before the gap ends; hence no mark can occur there and the alternative follows the coupled baseline actions. Every such round chooses a different arm and incurs at least \(g\) pseudo-regret. Summing all change times in that gap gives
\[
g\frac{L_j(L_j+1)}2\ge\frac g2L_j^2.
\]
Cauchy--Schwarz yields, pathwise,
\[
\sum_{\tau=2}^{K}\text{(regret before the first marked pull)}
\ge\frac g2\sum_jL_j^2
\ge\frac g2\frac{(q-m)^2}{m+1}.
\]
Average over challengers and baseline randomness. With
\(M_a\) the number of baseline pulls of challenger \(a\) in rounds \(2,\ldots,K\),
\[
\frac1n\sum_{a=2}^A\mathbb E_0[M_a]\le\frac{r_0}{gn}.
\]
For \(f(x)=(q-x)^2/(x+1)\), one has
\[
f''(x)=\frac{2(q+1)^2}{(x+1)^3}>0,\qquad
f'(x)=-\frac{(q-x)(q+x+2)}{(x+1)^2}\le0
\]
on \([0,q]\). Jensen's inequality and monotonicity therefore give, whenever \(r_0\le gnq/2\),
\[
\boxed{r_1\ge\frac{g^2nq}{8(r_0+gn)}.}
\]
This part is unchanged by the shape of \(R\); it only needs a perfectly observable separated signal event.

## 6. Upper algorithm and the matching restricted-family order

Let
\[
p=(A/T)^{5/6}.
\]
Until a signal reward in \(S\) is observed, independently choose a uniformly random challenger with probability \(p\), and arm 1 with probability \(1-p\). After a signal is observed on challenger \(a\), play \(a\) for the rest of the horizon.

There are no false alarms under the baseline. Thus
\[
r_0=gpT.
\]
Before a change, probing incurs at most \(gpT\) expected regret. After a change, the probability of detecting the signal in any round before detection is
\[
h=p\frac{4}{7n}.
\]
The expected detection time is at most \(1/h=7n/(4p)\). Every undetected post-change round has pseudo-regret at most \(2g\), so
\[
\boxed{r_1\le gpT+\frac{7gn}{2p}.}
\]

For the oracle benchmark
\[
\Xi(A,T;Q,B)=
\min\left\{T,
A+\sqrt{AQ}+(AQBT)^{1/3}
+\sqrt{AT}\min\{B,\sqrt B\}\right\},
\]
the baseline still satisfies \(A\le\Xi(A,T;Q_0,0)\le2A\). For every alternative, using
\(T/64\le Q\le T/16\) and \(B=1/4\), one obtains
\[
\frac{1}{\sqrt[3]{256}}(AT^2)^{1/3}
\le\Xi(A,T;Q,1/4)
\le4(AT^2)^{1/3}.
\]
Combining these estimates with \(n\le A\), \(T\ge32A\), and the displayed \(p\) gives the same order as the point-signal construction:
\[
\sup_{\nu\in\mathcal F_{\rm sep}}
\frac{\mathbb E_\nu[R_T]}{\Xi(A,T;Q(\nu),B(\nu))}
\le4(T/A)^{1/6}.
\]

The gap lower bound in Section 5 and the same oracle comparisons give
\[
\inf_{\pi\text{ not told }Q,B}
\sup_{\nu\in\mathcal F_{\rm sep}}
\frac{\mathbb E_\nu[R_T]}{\Xi(A,T;Q(\nu),B(\nu))}
\ge\frac1{49152}(T/A)^{1/6}.
\]
Thus this second, non-degenerate-signal family also has the restricted-family optimal order
\[
\boxed{\Theta((T/A)^{1/6}).}
\]

## 7. What this does and does not generalize

This removes the special deterministic point-mass signal. It allows a genuinely random signal distribution with positive variance and shows that the proof needs only a known measurable event that perfectly separates the signal component from the baseline component. More generally, any pair \((P,R)\) with a separating event and fixed mixture weight has the same exact one-step KL and a geometric detection delay.

It does not remove the separability promise. For overlapping supports, the signal event is no longer perfectly observable, the coupling may diverge before a detectable observation, and the probe-and-commit detector above is not justified. The unrestricted problem over arbitrary bounded selected-arm distributions with both \(Q\) and \(B\) unknown remains open.

## 8. Lean and independent-check status

- The finite PMF construction for the original point signal is being added in BudgetFreeBandits/PositiveNoisePMF.lean.
- The non-degenerate two-point signal PMF and this generalized separated-support theorem are not yet Lean-checked.
- Exact arithmetic is suitable for SymPy/Wolfram verification.
- SageMath, cvc5, and GAP are assigned finite-policy enumeration, SMT counterexample search, and symmetry reduction respectively; they are not reported as executed unless a corresponding run log is committed.
- The generic finite-history KL induction is now formalized in `BudgetFreeBandits/SequentialKL.lean`; its specialization to this signal distribution and the local-KL identity `log(7/3)` times pull probability remain unformalized.
- The gap-sum/Jensen proof and complete algorithm expected-regret theorem remain separate Lean obligations.


## 9. Novelty audit against the October 2026 literature

A primary-source comparison is now recorded after reading the full arXiv v1 text of [Xiaojin Zhang, *Variance-Aware Non-Stationary Bandits: All-Budget Regret Bounds and Adaptation Costs*, arXiv:2610.26116v1 (19 October 2026)](https://arxiv.org/abs/2610.26116).

That paper already proves the gap-counting/Jensen adaptation obstruction on a disclosed **deterministic** one-improvement family, gives a matching family-specific monitoring policy, and derives a competitive-ratio lower bound of order \(\Omega((T/A)^{1/4})\) relative to supplied-budget deterministic oracle rates. It explicitly says that general unknown-budget low-noise scheduling remains open. Therefore:
- gap counting, coupling until detection, Jensen averaging, and probe/commit monitoring are **not** claimed as new techniques here;
- the broad unknown-budget problem is not solved by this note;
- the present construction's distinct mathematical extension is to a disclosed finite family with strictly positive reward variance at every arm and time, including a genuinely non-degenerate signal law with a perfectly separating event;
- the resulting restricted-family exponent \(\Theta((T/A)^{1/6})\) is a proved claim on that constructed family only, and is weaker than the deterministic-family \((T/A)^{1/4}\) exponent in the cited paper. The two exponents have different oracle denominators / environment classes and should not be compared as if they were the same minimax problem.

The same paper characterizes all supplied \((Q,B)\) minimax rates up to a logarithmic factor in the noisy setting, but does not claim a matching unrestricted unknown-budget policy. The exact overlap with the present project is the open adaptation question and the use of an oblivious one-improvement family; the positive-variance separated-signal mixture is an explicit subproblem extension, not a resolution of the open question.

Further established ingredients include adversarial variation-adaptive bandits without a known variation budget (Karnin–Anava, NeurIPS 2016) and adaptive partial-observation quickest-change detection with information-theoretic delay bounds (Gopalan et al., NeurIPS 2021). These sources further prevent claiming generic novelty for unknown-variation adaptation or adaptive sensing/change detection. See [Karnin–Anava](https://papers.nips.cc/paper/6341-multi-armed-bandits-competing-with-optimal-sequences) and [Gopalan et al.](https://proceedings.neurips.cc/paper/2021/hash/f3a4ff4839c56a5f460c88cce3666a2b-Abstract.html).

**Novelty status:** unverified. The positive-variance distributional specialization may be worth retaining as a formally checked example, but publication-level originality requires a separate systematic search and expert review.
