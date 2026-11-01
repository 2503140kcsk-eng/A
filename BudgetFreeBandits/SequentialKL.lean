module

public import Mathlib
public import Mathlib.InformationTheory.KullbackLeibler.ChainRule

/-!
# Finite-horizon KL chain rule for adaptive sequential experiments

Each one-round transition kernel is a joint law of the next action and reward,
conditional on the complete past.  It may therefore encode an arbitrary
history-dependent randomized policy.  The theorem below is the finite
iteration of Mathlib's composition-product KL chain rule.
-/

noncomputable section

open MeasureTheory ProbabilityTheory
open scoped ProbabilityTheory ENNReal

set_option linter.style.haveILetI false

namespace BudgetFreeBandits

universe uA uX

/-- Full observed history before round t: all previous action/reward pairs. -/
def SequentialHistory (A : Type uA) (X : Type uX) :
    Nat → Type (max uA uX)
  | 0 => PUnit
  | t + 1 => SequentialHistory A X t × (A × X)

variable {A : Type uA} {X : Type uX}
  [MeasurableSpace A] [MeasurableSpace X]

/-- The recursively chosen product measurable space on every finite-history type. -/
@[instance_reducible]
def sequentialHistoryMeasurableSpace (t : Nat) :
    MeasurableSpace (SequentialHistory A X t) :=
  match t with
  | 0 => PUnit.instMeasurableSpace
  | t + 1 =>
      MeasurableSpace.prod
        (sequentialHistoryMeasurableSpace t)
        (MeasurableSpace.prod ‹MeasurableSpace A› ‹MeasurableSpace X›)

@[instance_reducible]
instance sequentialHistoryMeasurableSpaceInstance (t : Nat) :
    MeasurableSpace (SequentialHistory A X t) :=
  sequentialHistoryMeasurableSpace (A := A) (X := X) t

/-- Joint transition law for the next action and reward, given the complete past. -/
abbrev SequentialStep (t : Nat) :=
  Kernel (SequentialHistory A X t) (A × X)

/-- The law of the complete action/reward transcript after t rounds. -/
noncomputable def sequentialTranscript
    (step : (t : Nat) → SequentialStep (A := A) (X := X) t)
    (hStep : ∀ t, IsMarkovKernel (step t)) :
    (t : Nat) → Measure (SequentialHistory A X t)
  | 0 => Measure.dirac PUnit.unit
  | t + 1 =>
      letI : IsMarkovKernel (step t) := hStep t
      sequentialTranscript step hStep t ⊗ₘ step t

theorem sequentialTranscript_isProbability
    (step : (t : Nat) → SequentialStep (A := A) (X := X) t)
    (hStep : ∀ t, IsMarkovKernel (step t)) :
    ∀ t, IsProbabilityMeasure (sequentialTranscript step hStep t) := by
  intro t
  induction t with
  | zero =>
      simpa [sequentialTranscript, sequentialHistoryMeasurableSpace] using
        (inferInstance : IsProbabilityMeasure (Measure.dirac PUnit.unit))
  | succ t ih =>
      haveI : IsProbabilityMeasure (sequentialTranscript step hStep t) := ih
      haveI : IsMarkovKernel (step t) := hStep t
      simpa [sequentialTranscript, sequentialHistoryMeasurableSpace] using
        (inferInstance : IsProbabilityMeasure
          (sequentialTranscript step hStep t ⊗ₘ step t))

/-- Conditional KL cost at round t, evaluated under the baseline history law. -/
noncomputable def sequentialLocalKL
    (baseStep altStep :
      (t : Nat) → SequentialStep (A := A) (X := X) t)
    (hBase : ∀ t, IsMarkovKernel (baseStep t))
    (_hAlt : ∀ t, IsMarkovKernel (altStep t))
    (t : Nat) : ℝ≥0∞ := by
  letI : IsProbabilityMeasure (sequentialTranscript baseStep hBase t) :=
    sequentialTranscript_isProbability baseStep hBase t
  letI : IsMarkovKernel (baseStep t) := hBase t
  letI : IsMarkovKernel (altStep t) := _hAlt t
  exact InformationTheory.klDiv
    (sequentialTranscript baseStep hBase t ⊗ₘ baseStep t)
    (sequentialTranscript baseStep hBase t ⊗ₘ altStep t)

/--
**Finite-horizon adaptive KL chain rule.**  For two sequential experiments,
the KL divergence between their complete transcript laws is the sum of the
one-round conditional KL costs, with each cost evaluated under the baseline
history law.  The transition kernels can depend on the entire previous
history, so this theorem includes arbitrary adaptive randomized policies.
-/
theorem sequentialTranscript_kl_chain_rule
    (baseStep altStep :
      (t : Nat) → SequentialStep (A := A) (X := X) t)
    (hBase : ∀ t, IsMarkovKernel (baseStep t))
    (hAlt : ∀ t, IsMarkovKernel (altStep t)) :
    ∀ t,
      InformationTheory.klDiv
        (sequentialTranscript baseStep hBase t)
        (sequentialTranscript altStep hAlt t) =
      ∑ i ∈ Finset.range t, sequentialLocalKL baseStep altStep hBase hAlt i := by
  intro t
  induction t with
  | zero =>
      simp [sequentialTranscript, sequentialLocalKL, sequentialHistoryMeasurableSpace, InformationTheory.klDiv_self]
  | succ t ih =>
      haveI : IsProbabilityMeasure (sequentialTranscript baseStep hBase t) :=
        sequentialTranscript_isProbability baseStep hBase t
      haveI : IsProbabilityMeasure (sequentialTranscript altStep hAlt t) :=
        sequentialTranscript_isProbability altStep hAlt t
      haveI : IsMarkovKernel (baseStep t) := hBase t
      haveI : IsMarkovKernel (altStep t) := hAlt t
      rw [sequentialTranscript, sequentialTranscript,
        InformationTheory.klDiv_compProd_eq_add, ih]
      simp [sequentialLocalKL, Finset.sum_range_succ]

end BudgetFreeBandits
