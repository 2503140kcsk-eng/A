module

public import BudgetFreeBandits.PositiveNoisePMF
public import Mathlib.MeasureTheory.Measure.Decomposition.RadOnNikodym
public import Mathlib.MeasureTheory.Integral.Lebesgue.Countable

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

/-- The Radon--Nikodym density of the baseline law with respect to the
alternative law: 5/3 on baseline support and 0 on the marker. -/
def spikeDensity (i : Fin 3) : ℝ≥0∞ :=
  if i = 2 then 0 else 5 / 3

@[simp] theorem spikeDensity_zero : spikeDensity 0 = (5 / 3 : ℝ≥0∞) := by
  simp [spikeDensity]

@[simp] theorem spikeDensity_one : spikeDensity 1 = (5 / 3 : ℝ≥0∞) := by
  simp [spikeDensity]

@[simp] theorem spikeDensity_marker : spikeDensity 2 = 0 := by
  simp [spikeDensity]

/-- The baseline measure is the alternative measure weighted by spikeDensity. -/
theorem spikeBase_toMeasure_eq_withDensity :
    spikeAlternativePMF.toMeasure.withDensity spikeDensity =
      spikeBasePMF.toMeasure := by
  classical
  apply Measure.ext
  intro s hs
  rw [Measure.withDensity_apply spikeDensity hs, lintegral_fintype]
  rw [PMF.toMeasure_apply hs]
  simp only [PMF.toMeasure_apply_singleton]
  simp [spikeDensity, spikeBasePMF, spikeAlternativePMF, Fin.sum_univ_succ,
    Finset.sum_univ_succ, tsum_fintype]
  ring_nf

/-- The baseline measure is absolutely continuous with respect to the alternative. -/
theorem spikeBase_toMeasure_absolutelyContinuous :
    spikeBasePMF.toMeasure ≪ spikeAlternativePMF.toMeasure := by
  rw [← spikeBase_toMeasure_eq_withDensity]
  exact Measure.withDensity_absolutelyContinuous _ _

/-- The Radon--Nikodym derivative is exactly 5/3 on the baseline support and 0
on the marker, almost everywhere under the alternative law. -/
theorem spikeBase_rnDeriv_eq_density :
    (spikeBasePMF.toMeasure).rnDeriv (spikeAlternativePMF.toMeasure)
      =ᵐ[spikeAlternativePMF.toMeasure] spikeDensity := by
  rw [← spikeBase_toMeasure_eq_withDensity]
  have htop : ∀ᵐ i ∂spikeAlternativePMF.toMeasure, spikeDensity i ≠ ∞ :=
    ae_of_all _ (by intro i; fin_cases i <;> simp [spikeDensity])
  have h := Measure.rnDeriv_withDensity_left
    (μ := spikeAlternativePMF.toMeasure)
    (ν := spikeAlternativePMF.toMeasure)
    (f := spikeDensity)
    (by fun_prop)
    htop
  filter_upwards [h, Measure.rnDeriv_self spikeAlternativePMF.toMeasure] with i hi hs
  rw [hi, hs]
  simp

/-- Actual measure-theoretic KL, as defined by Mathlib, is the exact log(5/3). -/
theorem spike_measure_kl_exact :
    InformationTheory.klDiv spikeBasePMF.toMeasure spikeAlternativePMF.toMeasure =
      ENNReal.ofReal (Real.log (5 / 3)) := by
  rw [InformationTheory.klDiv_eq_lintegral_klFun_of_ac
    spikeBase_toMeasure_absolutelyContinuous]
  calc
    (∫⁻ i, ENNReal.ofReal
        (InformationTheory.klFun
          ((spikeBasePMF.toMeasure).rnDeriv
            (spikeAlternativePMF.toMeasure) i).toReal)
        ∂spikeAlternativePMF.toMeasure)
      =
      ∫⁻ i, ENNReal.ofReal
        (InformationTheory.klFun (spikeDensity i).toReal)
        ∂spikeAlternativePMF.toMeasure := by
          refine lintegral_congr_ae ?_
          filter_upwards [spikeBase_rnDeriv_eq_density] with i hi
          rw [hi]
    _ = ∑ i, ENNReal.ofReal
        (InformationTheory.klFun (spikeDensity i).toReal) *
          spikeAlternativePMF.toMeasure {i} := by
          rw [lintegral_fintype]
    _ = ENNReal.ofReal (Real.log (5 / 3)) := by
          simp [spikeDensity, spikeAlternativePMF,
            PMF.toMeasure_apply_singleton, InformationTheory.klFun,
            Fin.sum_univ_succ, Real.log_pos (by norm_num : (1 : ℝ) < 5 / 3)]
          ring

/-- The real-valued KL obtained from Mathlib's measure KL is log(5/3). -/
theorem spike_measure_kl_toReal_exact :
    (InformationTheory.klDiv spikeBasePMF.toMeasure
      spikeAlternativePMF.toMeasure).toReal = Real.log (5 / 3) := by
  rw [spike_measure_kl_exact, ENNReal.toReal_ofReal]
  exact Real.log_nonneg (by norm_num : (1 : ℝ) ≤ 5 / 3)

end BudgetFreeBandits
