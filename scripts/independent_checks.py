#!/usr/bin/env python3
"""Independent exact checks for the positive-noise one-change family.

Uses only the Python standard library. These finite checks are supplementary:
they are not proofs for all horizons/policies and never replace Lean.
"""
from fractions import Fraction as F
from itertools import combinations
from random import Random


def transcript_pmf(horizon: int, change_at: int, seed: int, alternative: bool):
    """Enumerate the transcript PMF for a fully history-dependent policy.

    Arm 0 is stable. Arm 1 is the potentially improved target.
    The same randomized action kernel is shared by both environments.
    """
    rng = Random(seed)
    policy_probabilities = {}

    def policy_target_probability(t, history):
        key = (t, history)
        if key not in policy_probabilities:
            policy_probabilities[key] = F(rng.randrange(1, 10), 10)
        return policy_probabilities[key]

    distribution = {(): F(1)}
    for t in range(horizon):
        next_distribution = {}
        for history, mass in distribution.items():
            p_target = policy_target_probability(t, history)
            for arm, p_arm in ((0, 1 - p_target), (1, p_target)):
                if alternative and arm == 1 and t >= change_at:
                    reward_law = (
                        (0, F(3, 10)),
                        (1, F(3, 10)),
                        (2, F(2, 5)),
                    )
                else:
                    reward_law = ((0, F(1, 2)), (1, F(1, 2)))
                for reward, p_reward in reward_law:
                    next_history = history + ((arm, reward),)
                    next_distribution[next_history] = (
                        next_distribution.get(next_history, F(0))
                        + mass * p_arm * p_reward
                    )
        distribution = next_distribution
    return distribution


def check_adaptive_kl(trials: int = 200) -> tuple[int, int]:
    seed_rng = Random(20261101)
    total_histories = 0
    for _ in range(trials):
        horizon = seed_rng.randrange(1, 6)
        change_at = seed_rng.randrange(0, horizon)
        seed = seed_rng.randrange(1, 10**9)
        baseline = transcript_pmf(horizon, change_at, seed, False)
        alternative = transcript_pmf(horizon, change_at, seed, True)
        assert sum(baseline.values()) == 1
        assert sum(alternative.values()) == 1

        for history, p in baseline.items():
            q = alternative[history]
            assert q > 0
            target_pulls = sum(
                1
                for t, (arm, _reward) in enumerate(history)
                if arm == 1 and t >= change_at
            )
            # The adaptive action-kernel factors cancel exactly.
            assert p / q == F(5, 3) ** target_pulls
        total_histories += len(baseline)
    return trials, total_histories


def check_gap_counting(q_max: int = 10) -> int:
    checked = 0
    for q in range(1, q_max + 1):
        rounds = list(range(2, q + 2))
        for pulls_count in range(q + 1):
            for pulls in combinations(rounds, pulls_count):
                sentinels = [1, *pulls, q + 2]
                gaps = [
                    sentinels[i + 1] - sentinels[i] - 1
                    for i in range(len(sentinels) - 1)
                ]
                assert sum(gaps) == q - pulls_count
                assert 2 * sum(x * (x + 1) // 2 for x in gaps) >= sum(
                    x * x for x in gaps
                )
                assert (pulls_count + 1) * sum(x * x for x in gaps) >= (
                    q - pulls_count
                ) ** 2
                checked += 1
    return checked


def check_variance_budgets(t_max: int = 240) -> int:
    checked = 0
    for horizon in range(64, t_max + 1):
        base_variance = F(1, 4096 * horizon)
        point_spike_variance = F(3, 32) + F(3, 5) * base_variance
        separated_signal_variance = (
            F(11, 224) + F(3, 7) * base_variance
        )
        for change_at in range(2, horizon // 2 + 1):
            point_budget = (
                (change_at - 1) * base_variance
                + (horizon - change_at + 1) * point_spike_variance
            )
            separated_budget = (
                (change_at - 1) * base_variance
                + (horizon - change_at + 1) * separated_signal_variance
            )
            assert F(3 * horizon, 64) <= point_budget <= F(horizon, 8)
            assert (
                F(horizon, 64)
                <= separated_budget
                <= F(horizon, 16)
            )
            checked += 1
    return checked


def main():
    trials, histories = check_adaptive_kl()
    gaps = check_gap_counting()
    budgets = check_variance_budgets()
    print(
        f"adaptive KL: PASS ({trials} randomized history-dependent policies; "
        f"{histories} baseline transcripts)"
    )
    print(f"gap counting / Cauchy: PASS ({gaps} pull subsets; q <= 10)")
    print(
        f"variance budgets: PASS ({budgets} exact rational (T, tau) pairs; "
        "point-spike and separated-signal families)"
    )


if __name__ == "__main__":
    main()
