module

public import BudgetFreeBandits.PositiveNoisePMF
public import Mathlib.Algebra.Order.Chebyshev

/-!
# Point-spike specialization of the one-step adaptive KL cost

The generic measure-theoretic sequential chain rule is in SequentialKL.lean.
This file specializes its finite conditional reward calculation to the
point-spike pair. The local divergence is the discrete finite-PMF KL sum
already defined in PositiveNoisePMF.lean.

The action is sampled from a history-dependent PMF. The action law is shared
between environments; only the selected reward law changes, and only at the
target action. Averaging the reward KL over the action PMF gives log(5/3)
times the conditional probability of selecting that action. A second finite
sum averages over baseline histories and rounds, yielding log(5/3) times the
baseline expected target-pull count.

This module deliberately does not identify the finite-PMF KL sum with
Mathlib's measure-level InformationTheory.klDiv. The archived attempt at
that bridge remains unverified; nor does this file claim to instantiate the
full transcript Markov kernels.
-/

noncomputable section

namespace BudgetFreeBandits

/-- If the action is not the changed arm, the reward law is unchanged. -/
def pointSpikeRewardLaw {A : ℕ} (target action : Fin A) : PMF (Fin 3) :=
  if action = target then spikeAlternativePMF else spikeBasePMF

/-- The KL of a PMF with itself is zero for the concrete baseline PMF. -/
theorem spike_pmf_self_kl_zero :
    pmfKL spikeBasePMF spikeBasePMF = 0 := by
  unfold pmfKL
  norm_num [spikeBasePMF, Fin.sum_univ_succ]

/--
Conditional reward KL after drawing an action from an arbitrary randomized
policy. The policy may depend on the entire observed history; at a fixed
history it is represented by a PMF on the finite action set.
-/
def pointSpikeActionLocalKL {A : ℕ}
    (policy : PMF (Fin A)) (target : Fin A) : ℝ :=
  ∑ action : Fin A,
    (policy action).toReal *
      pmfKL spikeBasePMF (pointSpikeRewardLaw target action)

/--
Exact local point-spike KL identity. The shared action randomization
cancels. Only the target action contributes, with one-step KL log(5/3).
-/
theorem pointSpike_action_local_kl_exact {A : ℕ}
    (policy : PMF (Fin A)) (target : Fin A) :
    pointSpikeActionLocalKL policy target =
      (policy target).toReal * Real.log (5 / 3) := by
  classical
  unfold pointSpikeActionLocalKL
  rw [Finset.sum_eq_single target]
  · simp [pointSpikeRewardLaw, spike_pmf_kl_exact]
  · intro action hmem hne
    simp [pointSpikeRewardLaw, hne, spike_pmf_self_kl_zero]
  · intro hnot
    exact (hnot (Finset.mem_univ target)).elim

/--
The baseline-history average of the conditional local KL at one round.
historyLaw is a genuine finite PMF of histories, and policy h is the
conditional action distribution after history h.
-/
def pointSpikeHistoryLocalKL {H A : ℕ}
    (historyLaw : PMF (Fin H))
    (policy : Fin H → PMF (Fin A)) (target : Fin A) : ℝ :=
  ∑ h : Fin H,
    (historyLaw h).toReal * pointSpikeActionLocalKL (policy h) target

/--
Expected target-action indicator at one round, written by conditioning on
the complete baseline history and then on the policy's action PMF.
-/
def pointSpikeExpectedTargetPull {H A : ℕ}
    (historyLaw : PMF (Fin H))
    (policy : Fin H → PMF (Fin A)) (target : Fin A) : ℝ :=
  ∑ h : Fin H, (historyLaw h).toReal * (policy h target).toReal

/--
Averaging the local reward KL over baseline histories is exactly
log(5/3) times the expected target-action indicator at that round.
-/
theorem pointSpike_history_local_kl_exact {H A : ℕ}
    (historyLaw : PMF (Fin H))
    (policy : Fin H → PMF (Fin A)) (target : Fin A) :
    pointSpikeHistoryLocalKL historyLaw policy target =
      Real.log (5 / 3) *
        pointSpikeExpectedTargetPull historyLaw policy target := by
  unfold pointSpikeHistoryLocalKL pointSpikeExpectedTargetPull
  calc
    (∑ h : Fin H,
        (historyLaw h).toReal * pointSpikeActionLocalKL (policy h) target)
      =
      ∑ h : Fin H,
        Real.log (5 / 3) *
          ((historyLaw h).toReal * (policy h target).toReal) := by
            apply Finset.sum_congr rfl
            intro h hh
            rw [pointSpike_action_local_kl_exact]
            ring
    _ = Real.log (5 / 3) *
        (∑ h : Fin H,
          (historyLaw h).toReal * (policy h target).toReal) := by
            rw [Finset.mul_sum]

/-- Sum of the per-round local KL costs over any finite set of rounds. -/
def pointSpikeFiniteLocalKL {T H A : ℕ}
    (changedRounds : Finset (Fin T))
    (historyLaw : Fin T → PMF (Fin H))
    (policy : Fin T → Fin H → PMF (Fin A)) (target : Fin A) : ℝ :=
  ∑ t ∈ changedRounds,
    pointSpikeHistoryLocalKL (historyLaw t) (policy t) target

/-- Baseline expected number of pulls of the target arm on the selected rounds. -/
def pointSpikeExpectedTargetPullCount {T H A : ℕ}
    (changedRounds : Finset (Fin T))
    (historyLaw : Fin T → PMF (Fin H))
    (policy : Fin T → Fin H → PMF (Fin A)) (target : Fin A) : ℝ :=
  ∑ t ∈ changedRounds,
    pointSpikeExpectedTargetPull (historyLaw t) (policy t) target

/--
Finite-history point-spike identity. Summing the conditional KL costs
over post-change rounds gives log(5/3) times the baseline expected number
of pulls of the changed arm. This is the finite-discrete local form of the
requested log(5/3) E_0[N_a] identity.
-/
theorem pointSpike_finite_history_kl_exact {T H A : ℕ}
    (changedRounds : Finset (Fin T))
    (historyLaw : Fin T → PMF (Fin H))
    (policy : Fin T → Fin H → PMF (Fin A)) (target : Fin A) :
    pointSpikeFiniteLocalKL changedRounds historyLaw policy target =
      Real.log (5 / 3) *
        pointSpikeExpectedTargetPullCount changedRounds historyLaw policy target := by
  unfold pointSpikeFiniteLocalKL pointSpikeExpectedTargetPullCount
  calc
    (∑ t ∈ changedRounds,
        pointSpikeHistoryLocalKL (historyLaw t) (policy t) target)
      =
      ∑ t ∈ changedRounds,
        Real.log (5 / 3) *
          pointSpikeExpectedTargetPull (historyLaw t) (policy t) target := by
            apply Finset.sum_congr rfl
            intro t ht
            exact pointSpike_history_local_kl_exact _ _ _
    _ = Real.log (5 / 3) *
        (∑ t ∈ changedRounds,
          pointSpikeExpectedTargetPull (historyLaw t) (policy t) target) := by
            rw [Finset.mul_sum]

/--
Finite Cauchy--Schwarz step for a collection of gap lengths. If there are
m+1 gaps whose total length is q-m, then their squared lengths sum to at
least (q-m)^2/(m+1). This isolates the path-counting inequality from the
history-to-gap encoding.
-/
theorem pointSpike_gap_square_lower
    {ι : Type*} (gaps : Finset ι) (gap : ι → ℝ) (m q : ℝ)
    (hcard : (gaps.card : ℝ) = m + 1)
    (hsum : (∑ i ∈ gaps, gap i) = q - m) :
    (q - m) ^ 2 ≤ (m + 1) * ∑ i ∈ gaps, gap i ^ 2 := by
  calc
    (q - m) ^ 2 = (∑ i ∈ gaps, gap i) ^ 2 := by rw [hsum]
    _ ≤ (gaps.card : ℝ) * ∑ i ∈ gaps, gap i ^ 2 :=
      sq_sum_le_card_mul_sum_sq
    _ = (m + 1) * ∑ i ∈ gaps, gap i ^ 2 := by rw [hcard]

end BudgetFreeBandits
