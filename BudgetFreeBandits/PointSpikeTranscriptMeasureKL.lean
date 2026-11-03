module

public import BudgetFreeBandits.PointSpikeFiniteHistory
public import BudgetFreeBandits.PointSpikeMeasureKL
public import Mathlib.MeasureTheory.Measure.WithDensity
public import Mathlib.InformationTheory.KullbackLeibler.Basic

noncomputable section

open MeasureTheory ProbabilityTheory
open scoped ENNReal

namespace BudgetFreeBandits

/-- The finite Radon--Nikodym density of p with respect to q. -/
def finitePMFRNdensity {α : Type*} (p q : PMF α) (x : α) : ℝ≥0∞ :=
  if p x = 0 then 0 else p x / q x

/-- Multiplying the finite density by q recovers p, assuming support inclusion. -/
theorem finitePMFRNdensity_mul {α : Type*}
    (p q : PMF α)
    (hSupport : ∀ x, p x ≠ 0 → q x ≠ 0)
    (x : α) :
    finitePMFRNdensity p q x * q x = p x := by
  by_cases hp : p x = 0
  · simp [finitePMFRNdensity, hp]
  · simp only [finitePMFRNdensity, if_neg hp]
    exact ENNReal.div_mul_cancel (hSupport x hp) (q.apply_ne_top x)

/-- The finite density is finite everywhere when p is supported by q. -/
theorem finitePMFRNdensity_ne_top {α : Type*}
    (p q : PMF α)
    (hSupport : ∀ x, p x ≠ 0 → q x ≠ 0)
    (x : α) :
    finitePMFRNdensity p q x ≠ ∞ := by
  by_cases hp : p x = 0
  · simp [finitePMFRNdensity, hp]
  · exact ENNReal.div_ne_top (p.apply_ne_top x) (hSupport x hp)

/--
For finite spaces with measurable singletons, q weighted by p/q is exactly p.
This is the atomwise Radon--Nikodym identity.
-/
theorem finitePMF_toMeasure_eq_withDensity {α : Type*}
    [Fintype α] [MeasurableSpace α] [MeasurableSingletonClass α]
    (p q : PMF α)
    (hSupport : ∀ x, p x ≠ 0 → q x ≠ 0) :
    q.toMeasure.withDensity (finitePMFRNdensity p q) = p.toMeasure := by
  classical
  apply Measure.ext
  intro s hs
  rw [withDensity_apply (finitePMFRNdensity p q) hs]
  rw [← lintegral_indicator hs, lintegral_fintype]
  rw [p.toMeasure_apply hs]
  simp only [PMF.toMeasure_apply_singleton, tsum_fintype]
  apply Finset.sum_congr rfl
  intro x hx
  by_cases hxs : x ∈ s
  · simp [Set.indicator_apply, hxs, finitePMFRNdensity_mul p q hSupport x]
  · simp [Set.indicator_apply, hxs]

/-- Support inclusion implies absolute continuity of the associated measures. -/
theorem finitePMF_toMeasure_absolutelyContinuous {α : Type*}
    [Fintype α] [MeasurableSpace α] [MeasurableSingletonClass α]
    (p q : PMF α)
    (hSupport : ∀ x, p x ≠ 0 → q x ≠ 0) :
    p.toMeasure ≪ q.toMeasure := by
  rw [← finitePMF_toMeasure_eq_withDensity p q hSupport]
  exact withDensity_absolutelyContinuous q.toMeasure (finitePMFRNdensity p q)

/-- The RN derivative of the finite PMF measure is the finite density AE. -/
theorem finitePMF_rnDeriv_eq_density {α : Type*}
    [Fintype α] [MeasurableSpace α] [MeasurableSingletonClass α]
    (p q : PMF α)
    (hSupport : ∀ x, p x ≠ 0 → q x ≠ 0) :
    p.toMeasure.rnDeriv q.toMeasure
      =ᵐ[q.toMeasure] finitePMFRNdensity p q := by
  rw [← finitePMF_toMeasure_eq_withDensity p q hSupport]
  have htop : ∀ᵐ x ∂q.toMeasure, finitePMFRNdensity p q x ≠ ∞ :=
    ae_of_all _ (finitePMFRNdensity_ne_top p q hSupport)
  have h := Measure.rnDeriv_withDensity_left
    (μ := q.toMeasure)
    (ν := q.toMeasure)
    (f := finitePMFRNdensity p q)
    (by fun_prop)
    htop
  have hself : q.toMeasure.rnDeriv q.toMeasure =ᵐ[q.toMeasure] 1 :=
    Measure.rnDeriv_self q.toMeasure
  filter_upwards [h, hself] with x hx hselfx
  rw [hx, hselfx]
  simp

/-- The log-likelihood ratio is the logarithm of the finite density AE. -/
theorem finitePMF_llr_eq_log_density_ae {α : Type*}
    [Fintype α] [MeasurableSpace α] [MeasurableSingletonClass α]
    (p q : PMF α)
    (hSupport : ∀ x, p x ≠ 0 → q x ≠ 0) :
    MeasureTheory.llr p.toMeasure q.toMeasure
      =ᵐ[p.toMeasure] fun x => Real.log (finitePMFRNdensity p q x).toReal := by
  filter_upwards [
    (finitePMF_toMeasure_absolutelyContinuous p q hSupport).ae_le
      (finitePMF_rnDeriv_eq_density p q hSupport)
  ] with x hx
  simp [MeasureTheory.llr, hx]

/--
The measure-theoretic KL for two finite PMFs is their discrete finite KL
sum whenever the first PMF is absolutely continuous with respect to the
second. The result uses Mathlib's actual InformationTheory.klDiv.
-/
theorem finitePMF_measureKL_toReal_eq_discrete {α : Type*}
    [Fintype α] [MeasurableSpace α] [MeasurableSingletonClass α]
    (p q : PMF α)
    (hSupport : ∀ x, p x ≠ 0 → q x ≠ 0) :
    (InformationTheory.klDiv p.toMeasure q.toMeasure).toReal =
      ∑ x, if p x = 0 then 0 else
        (p x).toReal * Real.log ((p x).toReal / (q x).toReal) := by
  have hEq : p.toMeasure Set.univ = q.toMeasure Set.univ := by simp
  rw [InformationTheory.toReal_klDiv_of_measure_eq
    (finitePMF_toMeasure_absolutelyContinuous p q hSupport) hEq]
  rw [integral_congr_ae (finitePMF_llr_eq_log_density_ae p q hSupport)]
  rw [PMF.integral_eq_sum]
  simp only [smul_eq_mul]
  apply Finset.sum_congr rfl
  intro x hx
  by_cases hp : p x = 0
  · simp [hp, finitePMFRNdensity, Real.log_zero]
  · simp [finitePMFRNdensity, hp, ENNReal.toReal_div]

/-- Complete histories form finite types at every finite horizon. -/
@[instance_reducible]
private def pointSpikeTranscriptFintype (A X : Type*) [Fintype A] [Fintype X] :
    (t : ℕ) → Fintype (SequentialHistory A X t)
  | 0 => by
      change Fintype PUnit
      infer_instance
  | t + 1 => by
      letI := pointSpikeTranscriptFintype A X t
      change Fintype (SequentialHistory A X t × (A × X))
      infer_instance

private instance instPointSpikeTranscriptFintype {A : ℕ} (t : ℕ) :
    Fintype (SequentialHistory (Fin A) (Fin 3) t) :=
  pointSpikeTranscriptFintype (Fin A) (Fin 3) t

/-- Complete finite histories carry the discrete measurable space. -/
private instance instPointSpikeTranscriptMeasurableSpace {A : ℕ} (t : ℕ) :
    MeasurableSpace (SequentialHistory (Fin A) (Fin 3) t) := ⊤

/-- Every singleton history is measurable. -/
private instance instPointSpikeTranscriptMeasurableSingleton {A : ℕ} (t : ℕ) :
    MeasurableSingletonClass (SequentialHistory (Fin A) (Fin 3) t) :=
  ⟨by intro h; trivial⟩

/--
The complete-history measure KL equals log(5/3) times the expected
number of post-change target-arm pulls, for every history-dependent
randomized policy shared by the two environments.
-/
theorem pointSpikeTranscript_measureKL_eq_log_mul_expected_pulls {A : ℕ}
    (policy : (t : ℕ) → SequentialHistory (Fin A) (Fin 3) t → PMF (Fin A))
    (target : Fin A) (tau t : ℕ) :
    (InformationTheory.klDiv
      (pointSpikeBaseTranscriptPMF policy t).toMeasure
      (pointSpikeAltTranscriptPMF policy target tau t).toMeasure).toReal =
        Real.log (5 / 3) * pointSpikeExpectedPullCount policy target tau t := by
  have hSupport :
      ∀ h, pointSpikeBaseTranscriptPMF policy t h ≠ 0 →
        pointSpikeAltTranscriptPMF policy target tau t h ≠ 0 :=
    pointSpikeAltTranscriptPMF_pos_of_base policy target tau
  rw [finitePMF_measureKL_toReal_eq_discrete
    (pointSpikeBaseTranscriptPMF policy t)
    (pointSpikeAltTranscriptPMF policy target tau t) hSupport]
  simpa [pointSpikeTranscriptDiscreteKL] using
    pointSpikeTranscriptDiscreteKL_eq_log_mul_expected_pulls policy target tau t

end BudgetFreeBandits
