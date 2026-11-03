module

public import Mathlib
public import Mathlib.InformationTheory.KullbackLeibler.ChainRule

/-!
# Positive-noise adaptation: exact one-step algebra and KL kernel rules

The probabilistic finite-history lower-bound induction is documented in
docs/POSITIVE_NOISE_ADAPTATION_THEOREM.md. This module kernel-checks the
Mathlib KL identities used at each adaptive round, the exact scalar
moment/KL calculations for the spike construction, and the final algebraic
competitive-ratio reduction from the stated frontier inequality.
-/

noncomputable section

namespace BudgetFreeBandits

open MeasureTheory ProbabilityTheory

/-- Mean of the pre-change challenger distribution. -/
def spikeBaseMean : ℝ := 3 / 8

/-- Probability of the identifiable reward-1 mark. -/
def spikeProbability : ℝ := 2 / 5

/-- Mean after mixing the baseline challenger law with the reward-1 atom. -/
def spikeAlternativeMean : ℝ :=
  (1 - spikeProbability) * spikeBaseMean + spikeProbability

theorem spike_alternative_mean_exact :
    spikeAlternativeMean = 5 / 8 := by
  norm_num [spikeAlternativeMean, spikeProbability, spikeBaseMean]

/-- Variance of a mixture of the baseline two-point law and a point mass at 1. -/
def spikeAlternativeVariance (s2 : ℝ) : ℝ :=
  (1 - spikeProbability) * s2 +
    spikeProbability * (1 - spikeProbability) * (1 - spikeBaseMean) ^ 2

theorem spike_alternative_variance_exact (s2 : ℝ) :
    spikeAlternativeVariance s2 = 3 / 32 + (3 / 5) * s2 := by
  norm_num [spikeAlternativeVariance, spikeProbability, spikeBaseMean]
  ring

/--
The one-step KL expression: the base law puts mass 1/2 on each of two
non-spike atoms, while the mixture puts mass 3/10 on each. The remaining
mixture mass 2/5 is at the additional atom 1.
-/
def spikeOneStepKL : ℝ :=
  (1 / 2) * Real.log ((1 / 2) / (3 / 10)) +
    (1 / 2) * Real.log ((1 / 2) / (3 / 10))

theorem spike_one_step_kl_exact :
    spikeOneStepKL = Real.log (5 / 3) := by
  unfold spikeOneStepKL
  have hratio : (1 / 2 : ℝ) / (3 / 10) = 5 / 3 := by norm_num
  rw [hratio]
  ring

theorem spike_one_step_kl_positive :
    0 < spikeOneStepKL := by
  rw [spike_one_step_kl_exact]
  exact Real.log_pos (by norm_num)

/-- Positive baseline variance used in the construction. -/
def spikeNoiseVariance (T : ℝ) : ℝ := 1 / (4096 * T)

theorem spike_noise_variance_positive {T : ℝ} (hT : 0 < T) :
    0 < spikeNoiseVariance T := by
  unfold spikeNoiseVariance
  positivity

theorem spike_baseline_budget_exact {T : ℝ} (hT : 0 < T) :
    T * spikeNoiseVariance T = 1 / 4096 := by
  unfold spikeNoiseVariance
  field_simp [ne_of_gt hT]

theorem spike_alternative_variance_lower {T : ℝ} (hT : 0 < T) :
    3 / 32 ≤ spikeAlternativeVariance (spikeNoiseVariance T) := by
  rw [spike_alternative_variance_exact]
  have hnonneg : 0 ≤ spikeNoiseVariance T := by
    unfold spikeNoiseVariance
    positivity
  nlinarith [hnonneg]

theorem spike_alternative_variance_upper {T : ℝ} (hT : 32 ≤ T) :
    spikeAlternativeVariance (spikeNoiseVariance T) ≤ 1 / 8 := by
  rw [spike_alternative_variance_exact]
  have hsmall : spikeNoiseVariance T ≤ 1 / 131072 := by
    unfold spikeNoiseVariance
    rw [div_le_iff₀ (by positivity : 0 < 4096 * T)]
    norm_num
    nlinarith
  nlinarith [hsmall]

/-- Exact variance-envelope budget of an early one-change alternative. -/
def spikeAlternativeBudget (T tau : ℝ) : ℝ :=
  (tau - 1) * spikeNoiseVariance T +
    (T - tau + 1) * spikeAlternativeVariance (spikeNoiseVariance T)

theorem spike_alternative_budget_bounds
    {T tau : ℝ}
    (hT : 32 ≤ T)
    (htau_lo : 2 ≤ tau)
    (htau_hi : tau ≤ T / 2) :
    3 * T / 64 ≤ spikeAlternativeBudget T tau ∧
      spikeAlternativeBudget T tau ≤ T / 8 := by
  have hTpos : 0 < T := by linarith
  have hbase_nonneg : 0 ≤ spikeNoiseVariance T := by
    unfold spikeNoiseVariance
    positivity
  have halt_hi :
      spikeAlternativeVariance (spikeNoiseVariance T) ≤ 1 / 8 :=
    spike_alternative_variance_upper hT
  have hbase_le : spikeNoiseVariance T ≤ 1 / 8 := by
    have hsmall : spikeNoiseVariance T ≤ 1 / 131072 := by
      unfold spikeNoiseVariance
      rw [div_le_iff₀ (by positivity : 0 < 4096 * T)]
      norm_num
      nlinarith
    exact le_trans hsmall (by norm_num : (1 / 131072 : ℝ) ≤ 1 / 8)
  have halt_lo :
      3 / 32 ≤ spikeAlternativeVariance (spikeNoiseVariance T) :=
    spike_alternative_variance_lower hTpos
  have hcoeff1 : 0 ≤ tau - 1 := by linarith
  have hcoeff2 : 0 ≤ T - tau + 1 := by linarith
  have hduration : T / 2 ≤ T - tau + 1 := by linarith
  constructor
  · have hfirst : 0 ≤ (tau - 1) * spikeNoiseVariance T :=
      mul_nonneg hcoeff1 hbase_nonneg
    have hsecond :
        (T - tau + 1) * (3 / 32) ≤
          (T - tau + 1) * spikeAlternativeVariance (spikeNoiseVariance T) :=
      mul_le_mul_of_nonneg_left halt_lo hcoeff2
    unfold spikeAlternativeBudget
    nlinarith [hfirst, hsecond, hduration]
  · have hfirst :
        (tau - 1) * spikeNoiseVariance T ≤ (tau - 1) * (1 / 8) :=
      mul_le_mul_of_nonneg_left hbase_le hcoeff1
    have hsecond :
        (T - tau + 1) * spikeAlternativeVariance (spikeNoiseVariance T) ≤
          (T - tau + 1) * (1 / 8) :=
      mul_le_mul_of_nonneg_left halt_hi hcoeff2
    unfold spikeAlternativeBudget
    nlinarith [hfirst, hsecond]

/--
Mathlib's KL chain rule shows that a common adaptive action kernel contributes
no extra divergence: conditional on the same history, the policy uses the
same action law under both environments.
-/
theorem adaptive_action_kernel_kl_cancels
    {H A : Type*} [MeasurableSpace H] [MeasurableSpace A]
    (mu nu : Measure H) (policy : Kernel H A)
    [IsFiniteMeasure mu] [IsFiniteMeasure nu] [IsMarkovKernel policy] :
    InformationTheory.klDiv (mu ⊗ₘ policy) (nu ⊗ₘ policy) =
      InformationTheory.klDiv mu nu := by
  exact InformationTheory.klDiv_compProd_left mu nu policy

/--
One adaptive round can be decomposed into its history KL plus the KL from
the selected-reward stage. The action-selection kernel is shared.
-/
theorem adaptive_round_kl_decomposition
    {H A X : Type*}
    [MeasurableSpace H] [MeasurableSpace A] [MeasurableSpace X]
    (mu nu : Measure H)
    (policy : Kernel H A)
    (baseReward alternativeReward : Kernel (H × A) X)
    [IsFiniteMeasure mu] [IsFiniteMeasure nu]
    [IsMarkovKernel policy]
    [IsMarkovKernel baseReward] [IsMarkovKernel alternativeReward] :
    InformationTheory.klDiv
        ((mu ⊗ₘ policy) ⊗ₘ baseReward)
        ((nu ⊗ₘ policy) ⊗ₘ alternativeReward) =
      InformationTheory.klDiv mu nu +
        InformationTheory.klDiv
          ((mu ⊗ₘ policy) ⊗ₘ baseReward)
          ((mu ⊗ₘ policy) ⊗ₘ alternativeReward) := by
  rw [InformationTheory.klDiv_compProd_eq_add]
  rw [InformationTheory.klDiv_compProd_left]

/--
If the competitive-ratio argument has reached its scalar product inequality,
then the desired sixth-root bound follows with an explicit universal constant.
This lemma isolates the final algebraic step from the probabilistic lower bound.
-/
theorem positive_noise_ratio_from_product
    {C rootZ : ℝ}
    (hC : 0 ≤ C)
    (hroot : 1 ≤ rootZ)
    (hproduct : rootZ ^ 2 ≤ 24576 * C * (C + 1)) :
    C ≥ rootZ / 49152 := by
  by_cases hCsmall : C ≤ 1
  · have hprod : C * (C + 1) ≤ 2 * C := by
      nlinarith [hC]
    have hsq : rootZ ^ 2 ≤ 49152 * C := by
      nlinarith [hproduct, hprod]
    have hroot_sq : rootZ ≤ rootZ ^ 2 := by
      nlinarith [sq_nonneg (rootZ - 1)]
    have hgoal : rootZ ≤ 49152 * C :=
      le_trans hroot_sq hsq
    nlinarith [hgoal]
  · have hCone : 1 ≤ C := le_of_not_ge hCsmall
    have hprod : C * (C + 1) ≤ 2 * C ^ 2 := by
      nlinarith [hCone]
    have hsq : rootZ ^ 2 ≤ 49152 * C ^ 2 := by
      nlinarith [hproduct, hprod]
    have hgoal : rootZ ≤ 49152 * C := by
      by_contra hnot
      have hlt : 49152 * C < rootZ := lt_of_not_ge hnot
      have hnonneg : 0 ≤ 49152 * C := by positivity
      have hmul : (49152 * C) ^ 2 < rootZ ^ 2 :=
        (sq_lt_sq₀ hnonneg (by linarith [hroot])).2 hlt
      nlinarith [hsq, hmul]
    nlinarith [hgoal]

end BudgetFreeBandits
