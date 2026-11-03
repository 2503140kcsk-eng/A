module

public import BudgetFreeBandits.PositiveNoisePMF
public import Mathlib.MeasureTheory.Measure.WithDensity
public import Mathlib.InformationTheory.KullbackLeibler.Basic

noncomputable section

open MeasureTheory ProbabilityTheory
open scoped ENNReal

namespace BudgetFreeBandits

/-- Finite outcome space with its discrete sigma-algebra. -/
local instance : MeasurableSpace (Fin 3) := ⊤

/-- The actual measure associated to the baseline PMF. -/
abbrev spikeBaseMeasure : Measure (Fin 3) :=
  PMF.toMeasure spikeBasePMF

/-- The actual measure associated to the alternative PMF. -/
abbrev spikeAlternativeMeasure : Measure (Fin 3) :=
  PMF.toMeasure spikeAlternativePMF

/-- Radon--Nikodym density of the baseline with respect to the alternative. -/
def spikeDensity (i : Fin 3) : ℝ≥0∞ :=
  if i = 2 then 0 else ENNReal.ofReal (5 / 3)

@[simp] theorem spikeDensity_zero : spikeDensity 0 = ENNReal.ofReal (5 / 3) := by
  simp [spikeDensity]

@[simp] theorem spikeDensity_one : spikeDensity 1 = ENNReal.ofReal (5 / 3) := by
  simp [spikeDensity]

@[simp] theorem spikeDensity_marker : spikeDensity 2 = 0 := by
  simp [spikeDensity]

/-- Pointwise density identity on every atom. -/
theorem spikeDensity_mul_alternative_eq_base (i : Fin 3) :
    spikeDensity i * spikeAlternativePMF i = spikeBasePMF i := by
  fin_cases i <;> norm_num [spikeDensity, spikeAlternativePMF, spikeBasePMF]

/-- The baseline measure is the alternative measure weighted by spikeDensity. -/
theorem spikeBase_toMeasure_eq_withDensity :
    spikeAlternativeMeasure.withDensity spikeDensity = spikeBaseMeasure := by
  classical
  apply Measure.ext
  intro s hs
  rw [withDensity_apply spikeDensity hs, ← lintegral_indicator hs, lintegral_fintype]
  rw [PMF.toMeasure_apply spikeBasePMF hs]
  simp only [spikeAlternativeMeasure, PMF.toMeasure_apply_singleton,
    tsum_fintype, Set.indicator_apply]
  apply Finset.sum_congr rfl
  intro i hi
  by_cases his : i ∈ s
  · simp [his, spikeDensity_mul_alternative_eq_base]
  · simp [his]

/-- The baseline measure is absolutely continuous with respect to the alternative. -/
theorem spikeBase_toMeasure_absolutelyContinuous :
    spikeBaseMeasure ≪ spikeAlternativeMeasure := by
  rw [← spikeBase_toMeasure_eq_withDensity]
  exact withDensity_absolutelyContinuous spikeAlternativeMeasure spikeDensity

/-- The Radon--Nikodym derivative is spikeDensity almost everywhere. -/
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

/-- Actual measure-theoretic KL, as defined by Mathlib, is log(5/3). -/
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
            PMF.toMeasure_apply_singleton]
          have hA : 0 ≤ (-2 / 3 : ℝ) + Real.log (5 / 3) * (5 / 3) := by
            have h := InformationTheory.klFun_nonneg
              (by norm_num : (0 : ℝ) ≤ 5 / 3)
            norm_num [InformationTheory.klFun] at h
            nlinarith
          have hx : 0 ≤ (5 / 3 : ℝ) := by norm_num
          rw [ENNReal.toReal_ofReal hx]
          have hcoef :
              (3 : ℝ≥0∞) / 10 = ENNReal.ofReal ((3 : ℝ) / 10) := by
            rw [ENNReal.ofReal_eq_coe_nnreal (by norm_num : (0 : ℝ) ≤ 3 / 10)]
            norm_num
          have hmark :
              (2 : ℝ≥0∞) / 5 = ENNReal.ofReal ((2 : ℝ) / 5) := by
            rw [ENNReal.ofReal_eq_coe_nnreal (by norm_num : (0 : ℝ) ≤ 2 / 5)]
            norm_num
          rw [hcoef, hmark, ← ENNReal.ofReal_mul hA,
            ← ENNReal.ofReal_mul (mul_nonneg hA (by norm_num : (0 : ℝ) ≤ 3 / 10)),
            ← ENNReal.ofReal_add
              (mul_nonneg (mul_nonneg hA (by norm_num : (0 : ℝ) ≤ 3 / 10))
                (by norm_num : (0 : ℝ) ≤ 2))
              (by norm_num : (0 : ℝ) ≤ 2 / 5)]
          congr 1
          ring

/-- Real-valued KL obtained from Mathlib's measure KL is exactly log(5/3). -/
theorem spike_measure_kl_toReal_exact :
    (InformationTheory.klDiv spikeBaseMeasure spikeAlternativeMeasure).toReal =
      Real.log (5 / 3) := by
  rw [spike_measure_kl_exact, ENNReal.toReal_ofReal]
  exact Real.log_nonneg (by norm_num : (1 : ℝ) ≤ 5 / 3)

end BudgetFreeBandits
