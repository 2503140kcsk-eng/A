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
  have h53 : ENNReal.ofReal (5 / 3 : ℝ) = (5 / 3 : ℝ≥0∞) := by
    rw [ENNReal.ofReal_eq_coe_nnreal (by norm_num)]
    rw [← ENNReal.coe_div (by norm_num : (3 : ℝ≥0) ≠ 0)]
    congr 1
    ext
    norm_num
  have hratNN : (5 / 3 : ℝ≥0) * (3 / 10 : ℝ≥0) = (1 / 2 : ℝ≥0) := by
    norm_num
  have hrat : (5 / 3 : ℝ≥0∞) * (3 / 10 : ℝ≥0∞) =
      (1 / 2 : ℝ≥0∞) := by
    rw [← ENNReal.coe_div (by norm_num : (3 : ℝ≥0) ≠ 0),
      ← ENNReal.coe_div (by norm_num : (10 : ℝ≥0) ≠ 0),
      ← ENNReal.coe_div (by norm_num : (2 : ℝ≥0) ≠ 0)]
    norm_cast
  fin_cases i <;>
    simp [spikeDensity, spikeAlternativePMF, spikeBasePMF, h53, hrat]

/-- The baseline measure is the alternative measure weighted by spikeDensity. -/
theorem spikeBase_toMeasure_eq_withDensity :
    spikeAlternativeMeasure.withDensity spikeDensity = spikeBaseMeasure := by
  classical
  apply Measure.ext
  intro s hs
  rw [withDensity_apply spikeDensity hs, ← lintegral_indicator hs, lintegral_fintype]
  rw [PMF.toMeasure_apply spikeBasePMF hs]
  simp only [spikeAlternativeMeasure, tsum_fintype, Set.indicator_apply]
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

/-- The log-likelihood ratio agrees with the finite density on the baseline support. -/
theorem spikeBase_llr_eq_log_density_ae :
    MeasureTheory.llr spikeBaseMeasure spikeAlternativeMeasure
      =ᵐ[spikeBaseMeasure] fun i => Real.log (spikeDensity i).toReal := by
  filter_upwards [
    spikeBase_toMeasure_absolutelyContinuous.ae_le spikeBase_rnDeriv_eq_density
  ] with i hi
  simp [MeasureTheory.llr, hi]

/-- The actual measure-theoretic KL, as defined by Mathlib, is log(5/3). -/
theorem spike_measure_kl_toReal_exact :
    (InformationTheory.klDiv spikeBaseMeasure spikeAlternativeMeasure).toReal =
      Real.log (5 / 3) := by
  have hEq : spikeBaseMeasure Set.univ = spikeAlternativeMeasure Set.univ := by
    simp [spikeBaseMeasure, spikeAlternativeMeasure]
  rw [InformationTheory.toReal_klDiv_of_measure_eq
    spikeBase_toMeasure_absolutelyContinuous hEq]
  rw [integral_congr_ae spikeBase_llr_eq_log_density_ae]
  rw [PMF.integral_eq_sum]
  norm_num [spikeBasePMF, spikeDensity, ENNReal.toReal_ofReal]


end BudgetFreeBandits
