module

public import Mathlib
public import Mathlib.Probability.ProbabilityMassFunction.Integrals
public import Mathlib.InformationTheory.KullbackLeibler.ChainRule

/-!
# Concrete finite PMFs for the positive-noise construction

Unlike the scalar identities in PositiveNoiseAdaptation.lean, this file defines
the baseline and alternative as genuine finite probability mass functions.
Expectations and variances are integrals against PMF.toMeasure.  The finite
KL expression is the standard discrete relative-entropy sum over the actual
point masses (with the usual zero-mass convention).
-/

noncomputable section

namespace BudgetFreeBandits

open MeasureTheory ProbabilityTheory
open scoped ENNReal

/-- Baseline law: equal mass on the two non-marker outcomes. -/
def spikeBasePMF : PMF (Fin 3) :=
  PMF.ofFintype
    (fun i => if i = 2 then 0 else (1 / 2 : ℝ≥0∞))
    (by
      norm_num [Fin.sum_univ_succ]
      exact ENNReal.inv_two_add_inv_two
    )

/-- Alternative law: contaminate the baseline by mass 2/5 on the marker. -/
def spikeAlternativePMF : PMF (Fin 3) :=
  PMF.ofFintype
    (fun i => if i = 2 then (2 / 5 : ℝ≥0∞) else (3 / 10 : ℝ≥0∞))
    (by
      norm_num [Fin.sum_univ_succ]
      calc
        (3 : ℝ≥0∞) / 10 + ((3 : ℝ≥0∞) / 10 + (2 : ℝ≥0∞) / 5)
            = (3 + (3 + 4)) / 10 := by
                have h : (2 : ℝ≥0∞) / 5 = 4 / 10 := by
                  apply (ENNReal.div_eq_div_iff
                    (a := 10) (b := 5) (c := 2) (d := 4)
                    (by norm_num) (by norm_num) (by norm_num) (by norm_num)).2
                  norm_num
                rw [h, ENNReal.div_add_div_same, ENNReal.div_add_div_same]
        _ = 1 := by
          norm_num [ENNReal.div_self]
    )

@[simp] theorem spikeBasePMF_zero :
    spikeBasePMF 0 = (1 / 2 : ℝ≥0∞) := by
  simp [spikeBasePMF]

@[simp] theorem spikeBasePMF_one :
    spikeBasePMF 1 = (1 / 2 : ℝ≥0∞) := by
  simp [spikeBasePMF]

@[simp] theorem spikeBasePMF_marker :
    spikeBasePMF 2 = 0 := by
  simp [spikeBasePMF]

@[simp] theorem spikeAlternativePMF_zero :
    spikeAlternativePMF 0 = (3 / 10 : ℝ≥0∞) := by
  simp [spikeAlternativePMF]

@[simp] theorem spikeAlternativePMF_one :
    spikeAlternativePMF 1 = (3 / 10 : ℝ≥0∞) := by
  simp [spikeAlternativePMF]

@[simp] theorem spikeAlternativePMF_marker :
    spikeAlternativePMF 2 = (2 / 5 : ℝ≥0∞) := by
  simp [spikeAlternativePMF]

/-- Outcome values: two nearby ordinary rewards and one perfectly identifiable mark. -/
def spikeReward (δ : ℝ) (i : Fin 3) : ℝ :=
  if i = 2 then 1 else if i = 0 then 3 / 8 - δ else 3 / 8 + δ

/-- The genuine expectation, defined as an integral against the PMF measure. -/
def pmfExpectation (p : PMF (Fin 3)) (f : Fin 3 → ℝ) : ℝ :=
  ∫ x, f x ∂p.toMeasure

/-- The genuine variance, defined as the second centered moment of that PMF measure. -/
def pmfVariance (p : PMF (Fin 3)) (f : Fin 3 → ℝ) : ℝ :=
  ∫ x, (f x - pmfExpectation p f) ^ 2 ∂p.toMeasure

/-- On a finite outcome space, the expectation integral is the PMF-weighted sum. -/
theorem pmfExpectation_eq_sum (p : PMF (Fin 3)) (f : Fin 3 → ℝ) :
    pmfExpectation p f = ∑ i, (p i).toReal * f i := by
  unfold pmfExpectation
  simpa [smul_eq_mul] using (PMF.integral_eq_sum p f)

/-- On a finite outcome space, variance is the corresponding centered PMF-weighted sum. -/
theorem pmfVariance_eq_sum (p : PMF (Fin 3)) (f : Fin 3 → ℝ) :
    pmfVariance p f =
      ∑ i, (p i).toReal * (f i - pmfExpectation p f) ^ 2 := by
  unfold pmfVariance
  simpa [smul_eq_mul] using
    (PMF.integral_eq_sum p (fun i => (f i - pmfExpectation p f) ^ 2))

/-- Actual mean of the baseline PMF. -/
theorem spike_pmf_base_mean (δ : ℝ) :
    pmfExpectation spikeBasePMF (spikeReward δ) = 3 / 8 := by
  rw [pmfExpectation_eq_sum]
  norm_num [spikeBasePMF, spikeReward, Fin.sum_univ_succ]
  ring

/-- Actual mean of the contaminated PMF. -/
theorem spike_pmf_alternative_mean (δ : ℝ) :
    pmfExpectation spikeAlternativePMF (spikeReward δ) = 5 / 8 := by
  rw [pmfExpectation_eq_sum]
  norm_num [spikeAlternativePMF, spikeReward, Fin.sum_univ_succ]
  ring

/-- Actual variance of the baseline PMF. -/
theorem spike_pmf_base_variance (δ : ℝ) :
    pmfVariance spikeBasePMF (spikeReward δ) = δ ^ 2 := by
  rw [pmfVariance_eq_sum, spike_pmf_base_mean]
  norm_num [spikeBasePMF, spikeReward, Fin.sum_univ_succ]
  ring

/-- Actual variance of the contaminated PMF. -/
theorem spike_pmf_alternative_variance (δ : ℝ) :
    pmfVariance spikeAlternativePMF (spikeReward δ) =
      3 / 32 + (3 / 5) * δ ^ 2 := by
  rw [pmfVariance_eq_sum, spike_pmf_alternative_mean]
  norm_num [spikeAlternativePMF, spikeReward, Fin.sum_univ_succ]
  ring

/-- Radius chosen in the horizon-dependent positive-noise construction. -/
def spikeRadius (T : ℝ) : ℝ :=
  1 / (64 * Real.sqrt T)

theorem spikeRadius_sq {T : ℝ} (hT : 0 < T) :
    spikeRadius T ^ 2 = 1 / (4096 * T) := by
  unfold spikeRadius
  rw [div_pow, mul_pow, Real.sq_sqrt (le_of_lt hT)]
  norm_num

/-- The base PMF has exactly the strictly positive variance budget used in the PR. -/
theorem spike_pmf_base_variance_exact {T : ℝ} (hT : 0 < T) :
    pmfVariance spikeBasePMF (spikeReward (spikeRadius T)) =
      1 / (4096 * T) := by
  rw [spike_pmf_base_variance, spikeRadius_sq hT]

/-- The alternative PMF has the exact positive variance used in the PR. -/
theorem spike_pmf_alternative_variance_exact {T : ℝ} (hT : 0 < T) :
    pmfVariance spikeAlternativePMF (spikeReward (spikeRadius T)) =
      3 / 32 + 3 / (20480 * T) := by
  rw [spike_pmf_alternative_variance, spikeRadius_sq hT]
  ring

/--
Discrete Kullback-Leibler divergence of finite PMFs, using their actual point
masses.  The zero-mass convention is the standard one: 0 log (0/q) = 0.
-/
def pmfKL (p q : PMF (Fin 3)) : ℝ :=
  ∑ i, if p i = 0 then 0 else
    (p i).toReal * Real.log ((p i).toReal / (q i).toReal)

/-- Log-likelihood ratio on a finite PMF space, with value zero off the first PMF's support. -/
def pmfLogLikelihood (p q : PMF (Fin 3)) (i : Fin 3) : ℝ :=
  if p i = 0 then 0 else
    Real.log ((p i).toReal / (q i).toReal)

/-- Discrete KL is exactly the expectation under P of its log-likelihood ratio. -/
theorem pmfKL_eq_expected_log_likelihood (p q : PMF (Fin 3)) :
    pmfKL p q = pmfExpectation p (pmfLogLikelihood p q) := by
  rw [pmfExpectation_eq_sum]
  unfold pmfKL pmfLogLikelihood
  classical
  refine Finset.sum_congr rfl ?_
  intro i hi
  by_cases hp : p i = 0
  · simp [hp]
  · simp [hp]

/-- The alternative law assigns positive mass to every point in the baseline support. -/
theorem spike_alternative_positive_on_base_support :
    ∀ i : Fin 3, spikeBasePMF i ≠ 0 → spikeAlternativePMF i ≠ 0 := by
  intro i hi
  fin_cases i <;> simp_all

/-- The concrete KL formula is the expected log-likelihood under the actual baseline PMF. -/
theorem spike_pmf_kl_as_expected_log_likelihood :
    pmfKL spikeBasePMF spikeAlternativePMF =
      pmfExpectation spikeBasePMF
        (pmfLogLikelihood spikeBasePMF spikeAlternativePMF) := by
  exact pmfKL_eq_expected_log_likelihood _ _

/-- Exact baseline-to-alternative KL, computed from the two genuine PMFs. -/
theorem spike_pmf_kl_exact :
    pmfKL spikeBasePMF spikeAlternativePMF = Real.log (5 / 3) := by
  unfold pmfKL
  norm_num [spikeBasePMF, spikeAlternativePMF, Fin.sum_univ_succ]
  ring

end BudgetFreeBandits
