module

public import BudgetFreeBandits.PositiveNoisePMF
public import Mathlib.Probability.ProbabilityMassFunction.Basic
public import Mathlib.Probability.ProbabilityMassFunction.Integrals
public import Mathlib.MeasureTheory.Measure.WithDensity

/-!
# Measure-theoretic KL for the concrete finite PMFs

This module bridges the finite PMF log-sum to Mathlib's actual
InformationTheory.klDiv on PMF.toMeasure.  It is intentionally specific to
the baseline/contaminated pair: the baseline is absolutely continuous with
respect to the alternative, although the reverse absolute continuity fails.
-/

noncomputable section

open MeasureTheory ProbabilityTheory
open scoped ENNReal

namespace BudgetFreeBandits

set_option maxHeartbeats 600000

/-- Finite outcome space with its discrete sigma-algebra. -/
local instance : MeasurableSpace (Fin 3) := ⊤

/-- The actual measure associated to the baseline PMF. -/
abbrev spikeBaseMeasure : Measure (Fin 3) :=
  PMF.toMeasure spikeBasePMF

/-- The actual measure associated to the alternative PMF. -/
abbrev spikeAlternativeMeasure : Measure (Fin 3) :=
  PMF.toMeasure spikeAlternativePMF

/-- The Radon--Nikodym density of the baseline law with respect to the
alternative law: 5/3 on baseline support and 0 on the marker. -/
def spikeDensity (i : Fin 3) : ℝ≥0∞ :=
  if i = 2 then 0 else ENNReal.ofReal (5 / 3)

@[simp] theorem spikeDensity_zero : spikeDensity 0 = ENNReal.ofReal (5 / 3) := by
  simp [spikeDensity]

@[simp] theorem spikeDensity_one : spikeDensity 1 = ENNReal.ofReal (5 / 3) := by
  simp [spikeDensity]

@[simp] theorem spikeDensity_marker : spikeDensity 2 = 0 := by
  simp [spikeDensity]

/-- The baseline measure is the alternative measure weighted by spikeDensity. -/
theorem spikeBase_toMeasure_eq_withDensity :
    spikeAlternativeMeasure.withDensity spikeDensity = spikeBaseMeasure := by
  classical
  apply Measure.ext
  intro s hs
  rw [withDensity_apply spikeDensity hs, ← lintegral_indicator hs, lintegral_fintype]
  rw [PMF.toMeasure_apply spikeBasePMF hs]
  simp only [PMF.toMeasure_apply_singleton spikeAlternativePMF]
  by_cases h0 : (0 : Fin 3) ∈ s
  · by_cases h1 : (1 : Fin 3) ∈ s <;>
      simp [spikeBaseMeasure, spikeAlternativeMeasure, spikeDensity,
        spikeBasePMF, spikeAlternativePMF, h0, h1, Fin.sum_univ_succ,
        tsum_fintype]
  · simp [spikeBaseMeasure, spikeAlternativeMeasure, spikeDensity,
      spikeBasePMF, spikeAlternativePMF, h0, Fin.sum_univ_succ, tsum_fintype]

/-- The baseline measure is absolutely continuous with respect to the alternative. -/
theorem spikeBase_toMeasure_absolutelyContinuous :
    spikeBaseMeasure ≪ spikeAlternativeMeasure := by
  rw [← spikeBase_toMeasure_eq_withDensity]
  exact withDensity_absolutelyContinuous spikeAlternativeMeasure spikeDensity

/-- The Radon--Nikodym derivative is exactly 5/3 on the baseline support and 0
on the marker, almost everywhere under the alternative law. -/
theorem spikeBase_rnDeriv_eq_density :
    spikeBaseMeasure.rnDeriv spikeAlternativeMeasure
      =ᵐ[spikeAlternativeMeasure] spikeDensity := by
  rw [← spikeBase_toMeasure_eq_withDensity]
  have htop : ∀ᵐ i ∂spikeAlternativeMeasure, spikeDensity i ≠ ∞ :=
    ae_of_all _ (by
      intro i
      fin_cases i <;> simp [spikeDensity])
  have h := Measure.rnDeriv_withDensity_left
    (μ := spikeAlternativeMeasure)
    (ν := spikeAlternativeMeasure)
    (f := spikeDensity)
    (by fun_prop)
    htop
  have hself :
      spikeAlternativeMeasure.rnDeriv spikeAlternativeMeasure
        =ᵐ[spikeAlternativeMeasure] 1 :=
    Measure.rnDeriv_self spikeAlternativeMeasure
  filter_upwards [h, hself] with i hi hs
  rw [hi, hs]
  simp

/-- Actual measure-theoretic KL, as defined by Mathlib, is the exact log(5/3). -/
theorem spike_measure_kl_exact :
    InformationTheory.klDiv spikeBaseMeasure spikeAlternativeMeasure =
      ENNReal.ofReal (Real.log (5 / 3)) := by
  rw [InformationTheory.klDiv_eq_lintegral_klFun_of_ac
    spikeBase_toMeasure_absolutelyContinuous]
  calc
    (∫⁻ i, ENNReal.ofReal
        (InformationTheory.klFun
          (spikeBaseMeasure.rnDeriv spikeAlternativeMeasure i).toReal)
        ∂spikeAlternativeMeasure)
      =
      ∫⁻ i, ENNReal.ofReal
        (InformationTheory.klFun (spikeDensity i).toReal)
        ∂spikeAlternativeMeasure := by
          refine lintegral_congr_ae ?_
          filter_upwards [spikeBase_rnDeriv_eq_density] with i hi
          rw [hi]
    _ = ∑ i, ENNReal.ofReal
        (InformationTheory.klFun (spikeDensity i).toReal) *
          spikeAlternativeMeasure {i} := by
          rw [lintegral_fintype]
    _ = ENNReal.ofReal (Real.log (5 / 3)) := by
          simp [spikeAlternativeMeasure, spikeDensity,
            InformationTheory.klFun, Fin.sum_univ_succ,
            PMF.toMeasure_apply_singleton spikeAlternativePMF]
          have hA : 0 ≤ (-2 / 3 : ℝ) + Real.log (5 / 3) * (5 / 3) := by
            have h := InformationTheory.klFun_nonneg
              (by norm_num : (0 : ℝ) ≤ 5 / 3)
            norm_num [InformationTheory.klFun] at h
            nlinarith
          have hcoef :
              (3 : ℝ≥0∞) / 10 = ENNReal.ofReal ((3 : ℝ) / 10) := by
            norm_num
          have htwo : (2 : ℝ≥0∞) = ENNReal.ofReal (2 : ℝ) := by
            norm_num
          have hmark :
              (2 : ℝ≥0∞) / 5 = ENNReal.ofReal ((2 : ℝ) / 5) := by
            norm_num
          rw [hcoef, htwo, hmark, ← ENNReal.ofReal_mul hA,
            ← ENNReal.ofReal_mul (mul_nonneg hA (by norm_num : (0 : ℝ) ≤ 3 / 10)),
            ← ENNReal.ofReal_add
              (mul_nonneg (mul_nonneg hA (by norm_num : (0 : ℝ) ≤ 3 / 10))
                (by norm_num : (0 : ℝ) ≤ 2))
              (by norm_num : (0 : ℝ) ≤ 2 / 5)]
          congr 1
          ring

/-- The real-valued KL obtained from Mathlib's measure KL is log(5/3). -/
theorem spike_measure_kl_toReal_exact :
    (InformationTheory.klDiv spikeBaseMeasure spikeAlternativeMeasure).toReal =
      Real.log (5 / 3) := by
  rw [spike_measure_kl_exact, ENNReal.toReal_ofReal]
  exact Real.log_nonneg (by norm_num : (1 : ℝ) ≤ 5 / 3)

end BudgetFreeBandits
