# Candidate KL lower bound for positive-noise one-change environments

**Status: CANDIDATE DERIVATION — NOT YET FORMALLY VERIFIED.**
**Novelty: UNKNOWN.** This is a research lead, not a claimed new theorem.

The purpose is to obtain a one-change lower bound in a genuinely noisy environment, rather than relying only on the zero-variance family from Theorem 5.1 of arXiv:2610.26116v1.

## 1. Environment family

Let A >= 2, n = A - 1, T >= 2, and choose g in (0,1/4]. There are A arms and T rounds.

Under the baseline environment P_0:
- arm 1 has Bernoulli(1/2) rewards at every round;
- every challenger arm a in {2,...,A} has Bernoulli(1/2-g) rewards at every round.

For a fixed change time tau in {1,...,T} and challenger a:
- all rewards match P_0 before tau;
- from tau through T, arm a has Bernoulli(1/2+g) rewards;
- all other arm distributions stay unchanged.

All reward draws are independent across rounds. The policy is an arbitrary fixed nonanticipating randomized policy; it is not told a or tau.

Write H = T - tau + 1 for the number of rounds after the change. Let
- r_0 = E_0[R_T] be the policy's expected pseudo-regret under the baseline;
- r_1 = max_{a in {2,...,A}} E_{a,tau}[R_T] be its worst expected pseudo-regret among the alternatives at this fixed tau.

The budgets of this family are explicit:
- at every round, arm 1 has variance 1/4 and every other arm has variance 1/4-g^2, so the variance envelope is exactly q_t=1/4 and Q=T/4;
- in an alternative, exactly one mean coordinate jumps from 1/2-g to 1/2+g, hence the consecutive mean-variation budget is B=2g;
- all rewards are bounded in [0,1] and have strictly positive variance.

This is therefore a positive-noise test family at the maximum variance budget, not a deterministic construction.

## 2. Candidate inequality

Let
[
d_g = D_{KL}(\operatorname{Ber}(1/2-g)\,\|\,\operatorname{Ber}(1/2+g))
= 2g\log\!\left(\frac{1/2+g}{1/2-g}\right).
]

The candidate claim is
[
\boxed{
r_1 \geq gH-\frac{r_0}{n}
-gH\sqrt{\frac{d_g r_0}{2gn}}
}
\tag{KL-1}
]

for every fixed nonanticipating policy and every fixed change time tau.

A direct consequence would be
[
r_0 \leq \frac{gn}{8}\min\left\{2H,\frac{1}{d_g}\right\}
\quad\Longrightarrow\quad
r_1 \geq \frac{gH}{2}.
\tag{KL-2}
]

For g <= 1/4, the elementary inequality
[
\log\frac{1+x}{1-x}\leq\frac{2x}{1-x^2}
\quad(0\leq x<1)
]
gives
[
d_g\leq\frac{8g^2}{1-4g^2}\leq\frac{32}{3}g^2.
]
Thus a sufficient condition for (KL-2) is
[
r_0 \leq \frac{gn}{8}\min\left\{2H,\frac{3}{32g^2}\right\}.
]

## 3. Proof route to check

1. Under P_0, each challenger pull incurs pseudo-regret g. Therefore
   [
   \sum_{a=2}^{A}\mathbb E_0[N_a(\tau,T)]\leq r_0/g.
   ]
   By averaging, there is a challenger a with
   [
   \mathbb E_0[N_a(\tau,T)]\leq r_0/(gn).
   ]

2. Let P_0^T and P_{a,tau}^T be the laws of the complete observable transcript (actions and rewards) under the two environments. Since the policy uses the same action kernel in both environments, the chain rule for relative entropy should give
   [
   D_{KL}(P_0^T\|P_{a,\tau}^T)
   =d_g\,\mathbb E_0[N_a(\tau,T)]
   \leq d_g r_0/(gn).
   ]
   This equality must be checked carefully for adaptive policies and their internal randomization.

3. Pinsker's inequality, with total variation defined by
   (\operatorname{TV}(P,Q)=\sup_E|P(E)-Q(E)|), gives
   [
   \operatorname{TV}(P_0^T,P_{a,\tau}^T)
   \leq\sqrt{d_g r_0/(2gn)}.
   ]

4. Since (0\leq N_a(\tau,T)\leq H), the expectation difference is bounded by H times total variation:
   [
   \mathbb E_{a,\tau}[N_a(\tau,T)]
   \leq \mathbb E_0[N_a(\tau,T)]
       +H\operatorname{TV}(P_0^T,P_{a,\tau}^T).
   ]

5. After tau, choosing any arm other than a incurs at least g regret in the alternative. Thus
   [
   \mathbb E_{a,\tau}[R_T]
   \geq g\bigl(H-\mathbb E_{a,\tau}[N_a(\tau,T)]\bigr),
   ]
   which yields (KL-1).

6. If (r_0\leq gnH/4), then (r_0/n\leq gH/4). If also (r_0\leq gn/(8d_g)), then the square-root term in (KL-1) is at most 1/4. Combining the two conditions gives (KL-2).

## 4. Why this is useful, and what it does not establish

- It supplies a transparent positive-noise environment with Q=T/4 and B=2g.
- It exposes the information cost of discovering one arm whose mean improves after a hidden change.
- It is a candidate lower-bound ingredient for the unknown-(Q,B) adaptation profile.

It does **not**:
- match the full two-dimensional oracle rate for arbitrary Q and B;
- provide an upper-bound algorithm;
- prove a minimax adaptation frontier;
- establish novelty relative to the bandit literature;
- have a Lean-checked probabilistic proof yet.

## 5. Mandatory audit before using it as a result

- Verify the chain-rule KL identity for arbitrary adaptive policies, including randomized policies.
- Check the transcript measurable space and the direction (D_{KL}(P_0\|P_{a,tau})).
- Confirm that the policy's action kernel is identical under the two environments conditional on each common history.
- Check the Pinsker and bounded-statistic total-variation constants.
- Search for an existing lower bound with the same one-improving-arm Bernoulli construction.
- Formalize the finite Bernoulli model and KL algebra in Lean before claiming a theorem.
