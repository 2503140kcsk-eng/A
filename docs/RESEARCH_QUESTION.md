# Research question and mathematical conventions

**Status: OPEN.** This records a research target, not a solved theorem.

## 1. Model

Fix integers A,T >= 2. Before interaction, an oblivious environment fixes reward laws nu_{t,a} supported on [0,1], for rounds t in [T] and arms a in [A]. Let mu_{t,a} be the mean and sigma^2_{t,a} the variance.

Reward draws are independent across rounds. Dependence among unobserved potential rewards of different arms within one round is immaterial because the learner observes only its selected reward. At round t, a nonanticipating randomized policy chooses a_t from the observed history and private randomness, then observes X_t distributed according to nu_{t,a_t}. The policy knows A and T, but the prior-free target does not reveal either global budget below.

Dynamic pseudo-regret:
R_T = sum_t (max_a mu_{t,a} - mu_{t,a_t}).

Per-round variance envelope:
q_t = max_a sigma^2_{t,a}, and V_T = sum_t q_t.

Consecutive mean variation, excluding any initial-vector term:
Delta_T = sum_{t=2}^T ||mu_t - mu_{t-1}||_infinity.

The global budgets are V_T <= Q and Delta_T <= B. The October 2026 reference paper uses Q in [0,T/4] and B in [0,T-1].

This is an **oblivious stochastic selected-arm-feedback model**. Adaptive environments, delayed feedback, contextual features, unbounded/heavy-tailed rewards, and dependent draws across rounds are outside the initial theorem unless introduced as a separately stated extension.

## 2. What is already known

Primary reference: Xiaojin Zhang, *Variance-Aware Non-Stationary Bandits: All-Budget Regret Bounds and Adaptation Costs*, arXiv:2610.26116v1, submitted 19 October 2026.

For a learner told A,T,Q,B, the paper defines
Xi(A,T;Q,B) = min{T, A + sqrt(AQ) + (AQBT)^(1/3) + sqrt(AT) min{B,sqrt(B)}}.

Theorem 4.1 gives universal constants c,C > 0 such that
c Xi(A,T;Q,B) <= R*(A,T;Q,B) <= C log(AT) Xi(A,T;Q,B).

Here the minimax policy may use the supplied budgets. For Q > 0 the paper states this is a one-logarithm characterization, not a constant-factor characterization; removing that logarithm is unresolved in that work. The deterministic boundary Q=0 is treated separately without logarithmic loss.

**Crucial distinction:** a theorem for supplied budgets does not automatically give one policy that works when the budgets are hidden. The paper explicitly says that no sharp all-budget guarantee is claimed for a policy not given Q,B.

## 3. Prior-free target

Let Pi(A,T) be policies whose inputs include A,T, but not Q,B, and which are fixed once for the full family of environments. For one policy pi, define
R_pi(Q,B) = sup over environments with V_T <= Q and Delta_T <= B of E[R_T].

The project seeks a sharp description of the attainable **profile** (R_pi(Q,B)) over one and the same policy, rather than optimizing a different policy separately for each budget pair.

Formally, let
P_{A,T} = { (Q,B) -> R_pi(Q,B) : pi in Pi(A,T) }.
Order profiles pointwise: f <= g when f(Q,B) <= g(Q,B) for every admissible pair (Q,B). The target is to characterize the non-dominated (Pareto-minimal) boundary of P_{A,T}, or prove a matching outer bound on that boundary.

This distinction matters. The pointwise infimum inf_pi R_pi(Q,B) can select a different policy for every budget pair and therefore does not solve the one-policy adaptation problem. The oracle benchmark Xi(A,T;Q,B) is a useful reference, but it is already known that one policy cannot match every supplied-budget deterministic oracle rate up to only logarithmic factors. The correct adaptation penalty must be determined rather than assumed to be polylogarithmic.

### Main research question

For the unrestricted noisy model above, what is the minimax attainable tradeoff between (i) stationary/low-variance guarantees and (ii) dynamic/variation-sensitive guarantees of a single policy not told Q or B? Can an explicit policy attain the Pareto boundary up to universal constants or logarithms, or is there a stronger information-theoretic obstruction?

This is a two-sided target: an impossibility theorem is a valid solution if it closes the stated profile problem.

## 4. Existing lower-bound structure to formalize

Section 5 of the reference paper studies a disclosed deterministic family. Fix g in (0,1/2]. The baseline has mean reward 1/2 on arm 1 and 1/2-g on every challenger. An alternative selects a challenger a >= 2 and change time tau in {2,...,T}, then changes that arm's mean to 1/2+g from tau onward. This family has zero reward variance and one mean change of size 2g.

Let n=A-1, q=T-1, r0 be baseline expected regret, and r1 worst-case expected regret over one-change alternatives. Theorem 5.1 states:
if r0 <= gnq/2, then r1 >= g^2*n*q / (8*(r0+g*n));
for every policy, r1 >= r0-g.

Theorem 5.2 gives a matching frontier, up to universal constants, on this disclosed deterministic family:
Phi_g(r) = min{gT, g sqrt(nT) + g^2*n*T/(r+g*n)}, for T >= 16A.

The first Lean milestone derives an algebraic corollary. Write u=sqrt(nq). If u^2=nq, u>=4, and n<=u, then the two Theorem 5.1 inequalities imply r1 >= gu/12. Split at r0=gu/2: above the split use r1>=r0-g; below it, r0<gu/2<=gnq/2, so the first Theorem 5.1 inequality applies, and its denominator is at most 12gu.

This formal corollary is a **derived consequence of a published preprint theorem**, not a new bandit lower bound. The probability/change-of-measure proof of Theorem 5.1 is not yet formalized in this repository.

## 5. Positive-noise lower-bound direction

A candidate Bernoulli one-change construction with variance budget Q=T/4 and variation budget B=2g is recorded in [NOISY_LOWER_BOUND_CANDIDATE.md](NOISY_LOWER_BOUND_CANDIDATE.md). It uses a KL chain-rule argument and Pinsker's inequality to seek a lower bound for policies with small baseline regret.

This is explicitly a candidate derivation, not a formally verified or novelty-checked theorem. Its role is to provide the first positive-variance attack on the unrestricted noisy problem.

## 6. Novelty guardrails

The project must not claim these as new:

1. Non-stationary bandits with an unknown variation budget in general. The reference paper cites earlier prior-free deterministic variation tracking, including a noiseless construction.
2. The supplied-(Q,B) minimax rate in Theorem 4.1.
3. The disclosed deterministic one-improvement frontier in Theorem 5.2.
4. A generic claim that switching-regret adaptation is impossible or open. A 2026 preprint, arXiv:2609.13547, reports a single algorithm adapting to unknown comparator switch count against oblivious adversaries, in a different adversarial switching-comparator formulation.

The novelty candidate is specifically the unrestricted noisy selected-arm-feedback model with both variance and mean-variation budgets unknown, and a matching description of the complete attainable adaptation profile.

## 7. What would count as a solution

At least one outcome is required:

- **Positive result:** an explicit prior-free policy, a rigorous expected or high-probability bound for every admissible Q,B, and a matching lower bound up to stated factors.
- **Negative result:** a lower bound ruling out a proposed adaptation profile for every nonanticipating randomized policy, with a matching attainable alternative or clearly characterized gap.
- **Structural theorem:** a proved decomposition of the attainable stationary/dynamic regret region reducing the problem to explicit inequalities, together with a proof that the reduction is exact.

A numerical experiment, solver output, proof sketch, or verified algebraic corollary alone does not solve the main problem.
