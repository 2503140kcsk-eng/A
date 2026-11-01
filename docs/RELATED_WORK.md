# Related-work audit and novelty boundaries

**Audit date: 1 November 2026.** This is a working audit, not a claim that every paper ever published has been exhaustively reviewed.

## Primary target paper

Xiaojin Zhang (19 October 2026), *Variance-Aware Non-Stationary Bandits: All-Budget Regret Bounds and Adaptation Costs*, arXiv:2610.26116v1.

- Abstract/version history: https://arxiv.org/abs/2610.26116
- Accessible HTML: https://arxiv.org/html/2610.26116v1
- Theorem 4.1: supplied variance and variation budgets; minimax expected dynamic regret characterized up to one logarithmic factor.
- Theorem 5.1/5.2: adaptation inequality and matching stationary-to-change-regret frontier on a disclosed deterministic one-improvement family.
- Section 6, “Unknown-budget scope”: explicitly says no sharp all-budget guarantee is claimed for a policy not given Q,B, and that removing both forms of side information while retaining variance-sensitive regret remains open.
- Conclusion: obtaining matching adaptation frontiers for unrestricted noisy environments remains open.

The paper itself should be read before every claimed advance. A change in notation, a different constant, or a restatement of its theorems is not a contribution.

## Prior results that rule out overclaiming

### Prior-free deterministic variation tracking

The target paper identifies a 2016 work under its bibliography key KA16. It states that the earlier work already studied adaptation to unknown variation and provides a prior-free deterministic guarantee of order
O(log(T) * [sqrt(A*T) + A^(1/3)*T^(2/3)*Delta^(1/3)]),
and that its supplementary Appendix D outlines, but defers, a general-arm noisy extension.

Implication: “unknown variation budget” and “zero-noise non-stationary bandits” are not novel problem formulations. The gap must specifically involve the simultaneous variance-sensitive and variation-sensitive profile in the unrestricted noisy selected-arm-feedback model. The reference paper's bibliography key is retained rather than guessing author metadata.

### Variance-sensitive non-stationary regret

The target paper discusses WHL16 and WXC+25 as prior variance-sensitive dynamic-regret work. It distinguishes their observation and budget conventions from its own: for example, full-vector variance versus the sum of the largest per-round arm variances, and variation conventions that may include an initial vector. A theorem with different definitions cannot be imported without proving the conversion and tracking dependence on A,T,Q,B.

### Stochastic variation-budget theory and restart methods

The target paper cites BGZ14/BGZ19 for classical stochastic variation-budget rates and WS24 for MOSS-based resetting, sliding-window, and discounted policies. These are important baselines, but their stochastic minimax lower bounds do not by themselves identify the minimax value of the deterministic subclass.

### Oracle-efficient online learning

Wang, Hu, Muthukumar, and Abernethy, *Adaptive Oracle-Efficient Online Learning*, NeurIPS 2022:
https://papers.nips.cc/paper_files/paper/2022/hash/948106cb5a114684a64c89a1e517e3fe-Abstract-Conference.html

Relevant to parameter adaptation and efficient meta-algorithms, but its oracle-efficient framework and assumptions are not automatically an upper bound for stochastic selected-arm feedback with unknown Q,B.

### Strongly adaptive online learning

Daniely et al., *Strongly Adaptive Online Learning* (2015):
https://proceedings.mlr.press/v37/daniely15.pdf

Supplies interval-wise regret concepts and algorithms in several full-information/online-convex settings. Its partial-feedback limitations matter: a full-information guarantee cannot be assumed to carry over to bandit feedback.

### A nearby 2026 problem reported solved

Mengxiao Zhang, *Toward Optimal Switching Regret for Multi-Armed Bandits with Oblivious Adversary*, arXiv:2609.13547:
https://arxiv.org/abs/2609.13547

The abstract reports an algorithm adapting to an unknown comparator switch count S against an oblivious adversary, resolving a prior open problem in that formulation. This is not the same target: our initial model is stochastic, uses dynamic best-arm regret, and asks for simultaneous adaptation to a reward-variance envelope and a mean-variation budget. Definitions must be compared before borrowing any construction.

## Literature-audit rules

For every proposed theorem:
1. Search title, abstract, and exact bound separately.
2. Search cited papers and supplementary materials, not only abstracts.
3. Check feedback model (full information, bandit, semi-bandit, or direct stream).
4. Check comparator (static arm, dynamic best arm, switching arm sequence, or policy class).
5. Check whether Q,B, switch count, horizon, gap, or structural promise is supplied to the learner.
6. Check whether the theorem is expected, high probability, pathwise, or asymptotic.
7. Check reward range, independence, filtration, and budget definitions.
8. Record earliest relevant publication version and later updates.
9. Record what is already solved and explicitly state the remaining gap.

An arXiv preprint is evidence of a public research claim, not peer-reviewed consensus. Novelty status is provisional until independent literature review.
