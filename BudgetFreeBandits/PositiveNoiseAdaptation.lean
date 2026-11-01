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
  norm_num

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
  have hbase_le : spikeNoiseVariance T ≤ 1 / 8 := by
    have hbase_eq : spikeNoiseVariance T ≤
        spikeAlternativeVariance (spikeNoiseVariance T) := by
      unfold spikeNoiseVariance
      rw [div_le_iff₀ (by positivity : 0 < 4096 * T)]
      norm_num
      nlinarith
    exact le_trans hbase_eq hvar
  have halt_lo :
      3 / 32 ≤ spikeAlternativeVariance (spikeNoiseVariance T) :=
    spike_alternative_variance_lower hTpos
  have halt_hi :
      spikeAlternativeVariance (spikeNoiseVariance T) ≤ 1 / 8 :=
    spike_alternative_variance_upper hT
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
Algebraic reduction used in the positive-noise oracle-competitive lower bound.
Here scaleU^3 = A*T^2 and T = scaleU*rootZ^2, so rootZ = (T/A)^(1/6).
The input inequalities are precisely the oracle-rate comparisons and the
positive-noise frontier proved in the accompanying research note.
-/
theorem positive_noise_competitive_ratio_lower
    {A T n q C r0 r1 scaleU rootZ : ℝ}
    (hA : 2 ≤ A)
    (hT : 32 * A ≤ T)
    (hn_lo : A / 2 ≤ n)
    (hn_hi : n ≤ A)
    (hq_lo : T / 3 ≤ q)
    (hC : 0 ≤ C)
    (hr0_nonneg : 0 ≤ r0)
    (hr1_nonneg : 0 ≤ r1)
    (hscale_nonneg : 0 ≤ scaleU)
    (hscale_cube : scaleU ^ 3 = A * T ^ 2)
    (hroot : 1 ≤ rootZ)
    (hscale_relation : T = scaleU * rootZ ^ 2)
    (hbase_oracle : r0 ≤ 2 * A * C)
    (halt_oracle : r1 ≤ 4 * C * scaleU)
    (hfrontier :
      r0 < n * q / 16 →
        r1 ≥ (n * q) / (512 * (r0 + n / 8))) :
    C ≥ rootZ / 49152 := by
  have hApos : 0 < A := by linarith
  have hTpos : 0 < T := by linarith
  have hnpos : 0 < n := by linarith
  have hqpos : 0 < q := by linarith
  have hUpos : 0 < scaleU := by
    have hcube_pos : 0 < scaleU ^ 3 := by
      rw [hscale_cube]
      positivity
    nlinarith
  have hTgeA : A ≤ T := by linarith
  have hfactor : 0 ≤ A * (T - A) * (T + A) := by positivity
  have hAcube : A ^ 3 ≤ scaleU ^ 3 := by
    rw [hscale_cube]
    nlinarith [hfactor]
  have hAleU : A ≤ scaleU := by
    by_contra hnot
    have hlt : scaleU < A := lt_of_not_ge hnot
    have hdiff : 0 < (A - scaleU) *
        (A ^ 2 + A * scaleU + scaleU ^ 2) := by
      positivity
    nlinarith [hdiff, hAcube]
  have hroot_sq : 1 ≤ rootZ ^ 2 := by
    nlinarith [sq_nonneg (rootZ - 1)]
  have hroot_le_T : rootZ ≤ T := by
    rw [hscale_relation]
    nlinarith [hAleU, hroot_sq]
  have hnq : A * T / 6 ≤ n * q := by
    have hmul1 : A * T / 6 ≤ n * T / 3 := by
      nlinarith [hn_lo]
    have hmul2 : n * T / 3 ≤ n * q := by
      nlinarith [hq_lo, hnpos]
    exact le_trans hmul1 hmul2
  by_cases hlarge : n * q / 16 ≤ r0
  · have hC_T : T / 192 ≤ C := by
      nlinarith [hlarge, hbase_oracle, hnq, hApos]
    have hz_bound : rootZ / 49152 ≤ T / 192 := by
      nlinarith [hroot_le_T]
    linarith
  · have hsmall : r0 < n * q / 16 := lt_of_not_ge hlarge
    have hfront := hfrontier hsmall
    have hdenpos : 0 < 512 * (r0 + n / 8) := by positivity
    have hfront_mul :
        n * q ≤ 512 * (r0 + n / 8) * r1 :=
      (div_le_iff₀ hdenpos).mp hfront
    have hdenbound : r0 + n / 8 ≤ 2 * A * (C + 1) := by
      nlinarith [hbase_oracle, hn_hi, hC]
    have hmulbound :
        512 * (r0 + n / 8) * r1 ≤
          1024 * A * (C + 1) * r1 := by
      have hmul := mul_le_mul_of_nonneg_right hdenbound hr1_nonneg
      nlinarith [hmul]
    have hmain : n * q ≤ 1024 * A * (C + 1) * r1 :=
      le_trans hfront_mul hmulbound
    have hA_scaled :
        A * (T / 6) ≤ A * (1024 * (C + 1) * r1) := by
      nlinarith [hnq, hmain]
    have hdivide :
        T / 6 ≤ 1024 * (C + 1) * r1 := by
      by_contra hnot
      have hlt : 1024 * (C + 1) * r1 < T / 6 := lt_of_not_ge hnot
      have hmul_lt :=
        mul_lt_mul_of_pos_left hlt hApos
      linarith
    have hbound : T ≤ 6144 * (C + 1) * r1 := by
      nlinarith [hdivide]
    have hfinal :
        T ≤ 24576 * C * scaleU * (C + 1) := by
      have hmul := mul_le_mul_of_nonneg_left halt_oracle
        (by positivity : 0 ≤ 6144 * (C + 1))
      nlinarith [hbound, hmul]
    have hratio :
        scaleU * rootZ ^ 2 ≤
          scaleU * (24576 * C * (C + 1)) := by
      rw [← hscale_relation]
      nlinarith [hfinal]
    have hroot_main :
        rootZ ^ 2 ≤ 24576 * C * (C + 1) := by
      by_contra hnot
      have hlt : 24576 * C * (C + 1) < rootZ ^ 2 := lt_of_not_ge hnot
      have hmul_lt := mul_lt_mul_of_pos_left hlt hUpos
      nlinarith [hratio, hmul_lt]
    by_cases hC_ge_one : 1 ≤ C
    · have hprod :
        C * (C + 1) ≤ 2 * C ^ 2 := by
          have hmul := mul_le_mul_of_nonneg_left
            (show C + 1 ≤ 2 * C by linarith) (le_of_lt (lt_of_lt_of_le zero_lt_one hC_ge_one))
          nlinarith [hmul]
      have hsq : rootZ ^ 2 ≤ 49152 * C ^ 2 := by
        nlinarith [hroot_main, hprod]
      have hgoal : rootZ ≤ 49152 * C := by
        by_contra hnot
        have hlt : 49152 * C < rootZ := lt_of_not_ge hnot
        have hpos : 0 ≤ 49152 * C := by positivity
        have hsq_lt :
            (49152 * C) ^ 2 < rootZ ^ 2 :=
          (sq_lt_sq₀ hpos (by linarith [hroot]) ).2 hlt
        nlinarith [hsq, hsq_lt]
      exact (le_div_iff₀ (by norm_num : (0 : ℝ) < 49152)).2 (by nlinarith [hgoal])
    · have hprod :
        C * (C + 1) ≤ 2 * C := by
          have hmul := mul_le_mul_of_nonneg_left
            (show C + 1 ≤ 2 by linarith) hC
          nlinarith [hmul]
      have hsq : rootZ ^ 2 ≤ 49152 * C := by
        nlinarith [hroot_main, hprod]
      have hroot_le_sq : rootZ ≤ rootZ ^ 2 := by
        nlinarith [sq_nonneg (rootZ - 1)]
      have hgoal : rootZ ≤ 49152 * C := le_trans hroot_le_sq hsq
      exact (le_div_iff₀ (by norm_num : (0 : ℝ) < 49152)).2 (by nlinarith [hgoal])

end BudgetFreeBandits
