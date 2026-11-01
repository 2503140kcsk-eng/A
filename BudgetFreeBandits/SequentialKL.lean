module

public import Mathlib
public import Mathlib.InformationTheory.KullbackLeibler.ChainRule

/-!
# Finite-horizon KL chain rule for fully history-adaptive policies

The policy at round t is an arbitrary Markov kernel from the complete
previous transcript to the next action.  Thus this theorem does not impose
stationarity or a non-adaptive action schedule.
-/

noncomputable section

open MeasureTheory ProbabilityTheory
open scoped ProbabilityTheory ENNReal

namespace BudgetFreeBandits

/-- Full observed history before round t: all previous actions and rewards. -/
universe uA uX

def SequentialHistory (A : Type uA) (X : Type uX) : Nat → Type (max uA uX)
  | 0 => PUnit
  | t + 1 => SequentialHistory A X t × (A × X)

variable {A X : Type*} [MeasurableSpace A] [MeasurableSpace X]

/-- The recursive finite-history space carries the product measurable space. -/
instance sequentialHistoryMeasurableSpace (t : Nat) :
    MeasurableSpace (SequentialHistory A X t) := by
  induction t with
  | zero => exact ⊤
  | succ t ih =>
      letI : MeasurableSpace (SequentialHistory A X t) := ih
      infer_instance

/-- One-round joint action/reward kernel, allowing the action law to depend
on the complete current history. -/
noncomputable def sequentialStepKernel
    (policy : (t : Nat) → Kernel (SequentialHistory A X t) A)
    (reward : (t : Nat) → Kernel (SequentialHistory A X t × A) X)
    (hPolicy : ∀ t, IsMarkovKernel (policy t))
    (hReward : ∀ t, IsMarkovKernel (reward t))
    (t : Nat) : Kernel (SequentialHistory A X t) (A × X) := by
  letI : IsMarkovKernel (policy t) := hPolicy t
  letI : IsMarkovKernel (reward t) := hReward t
  exact policy t ⊗ₖ reward t

theorem sequentialStepKernel_isMarkov
    (policy : (t : Nat) → Kernel (SequentialHistory A X t) A)
    (reward : (t : Nat) → Kernel (SequentialHistory A X t × A) X)
    (hPolicy : ∀ t, IsMarkovKernel (policy t))
    (hReward : ∀ t, IsMarkovKernel (reward t))
    (t : Nat) :
    IsMarkovKernel (sequentialStepKernel policy reward hPolicy hReward t) := by
  dsimp [sequentialStepKernel]
  letI : IsMarkovKernel (policy t) := hPolicy t
  letI : IsMarkovKernel (reward t) := hReward t
  infer_instance

/-- Law of the complete action/reward transcript through t rounds. -/
noncomputable def sequentialTranscript
    (policy : (t : Nat) → Kernel (SequentialHistory A X t) A)
    (reward : (t : Nat) → Kernel (SequentialHistory A X t × A) X)
    (hPolicy : ∀ t, IsMarkovKernel (policy t))
    (hReward : ∀ t, IsMarkovKernel (reward t)) :
    (t : Nat) → Measure (SequentialHistory A X t)
  | 0 => Measure.dirac PUnit.unit
  | t + 1 =>
      letI : IsMarkovKernel (sequentialStepKernel policy reward hPolicy hReward t) :=
        sequentialStepKernel_isMarkov policy reward hPolicy hReward t
      sequentialTranscript policy reward hPolicy hReward t ⊗ₘ
        sequentialStepKernel policy reward hPolicy hReward t

theorem sequentialTranscript_isProbability
    (policy : (t : Nat) → Kernel (SequentialHistory A X t) A)
    (reward : (t : Nat) → Kernel (SequentialHistory A X t × A) X)
    (hPolicy : ∀ t, IsMarkovKernel (policy t))
    (hReward : ∀ t, IsMarkovKernel (reward t)) :
    ∀ t, IsProbabilityMeasure (sequentialTranscript policy reward hPolicy hReward t) := by
  intro t
  induction t with
  | zero =>
      simpa [sequentialTranscript] using
        (inferInstance : IsProbabilityMeasure (Measure.dirac PUnit.unit))
  | succ t ih =>
      letI : IsProbabilityMeasure
          (sequentialTranscript policy reward hPolicy hReward t) := ih
      letI : IsMarkovKernel (sequentialStepKernel policy reward hPolicy hReward t) :=
        sequentialStepKernel_isMarkov policy reward hPolicy hReward t
      simpa [sequentialTranscript] using
        (inferInstance : IsProbabilityMeasure
          (sequentialTranscript policy reward hPolicy hReward t ⊗ₘ
            sequentialStepKernel policy reward hPolicy hReward t))

/-- Conditional KL cost of round t, evaluated under the baseline history law.
The two environments share the same history-dependent action kernel. -/
noncomputable def sequentialLocalKL
    (policy : (t : Nat) → Kernel (SequentialHistory A X t) A)
    (baseReward : (t : Nat) → Kernel (SequentialHistory A X t × A) X)
    (altReward : (t : Nat) → Kernel (SequentialHistory A X t × A) X)
    (hPolicy : ∀ t, IsMarkovKernel (policy t))
    (hBase : ∀ t, IsMarkovKernel (baseReward t))
    (hAlt : ∀ t, IsMarkovKernel (altReward t))
    (t : Nat) : ℝ≥0∞ := by
  letI : IsProbabilityMeasure
      (sequentialTranscript policy baseReward hPolicy hBase t) :=
    sequentialTranscript_isProbability policy baseReward hPolicy hBase t
  letI : IsMarkovKernel (sequentialStepKernel policy baseReward hPolicy hBase t) :=
    sequentialStepKernel_isMarkov policy baseReward hPolicy hBase t
  letI : IsMarkovKernel (sequentialStepKernel policy altReward hPolicy hAlt t) :=
    sequentialStepKernel_isMarkov policy altReward hPolicy hAlt t
  exact InformationTheory.klDiv
    (sequentialTranscript policy baseReward hPolicy hBase t ⊗ₘ
      sequentialStepKernel policy baseReward hPolicy hBase t)
    (sequentialTranscript policy baseReward hPolicy hBase t ⊗ₘ
      sequentialStepKernel policy altReward hPolicy hAlt t)

/--
**Finite-horizon adaptive KL chain rule.**  The KL divergence between the laws
of the complete transcripts is the sum of the per-round conditional KL costs.
The action policy may be an arbitrary Markov kernel of the complete prior
history, and it is shared by the two environments.
-/
theorem sequentialTranscript_kl_chain_rule
    (policy : (t : Nat) → Kernel (SequentialHistory A X t) A)
    (baseReward : (t : Nat) → Kernel (SequentialHistory A X t × A) X)
    (altReward : (t : Nat) → Kernel (SequentialHistory A X t × A) X)
    (hPolicy : ∀ t, IsMarkovKernel (policy t))
    (hBase : ∀ t, IsMarkovKernel (baseReward t))
    (hAlt : ∀ t, IsMarkovKernel (altReward t)) :
    ∀ t,
      InformationTheory.klDiv
        (sequentialTranscript policy baseReward hPolicy hBase t)
        (sequentialTranscript policy altReward hPolicy hAlt t) =
      ∑ i ∈ Finset.range t,
        sequentialLocalKL policy baseReward altReward hPolicy hBase hAlt i := by
  intro t
  induction t with
  | zero =>
      rw [sequentialTranscript]
      simp [InformationTheory.klDiv_self]
  | succ t ih =>
      letI : IsProbabilityMeasure
          (sequentialTranscript policy baseReward hPolicy hBase t) :=
        sequentialTranscript_isProbability policy baseReward hPolicy hBase t
      letI : IsProbabilityMeasure
          (sequentialTranscript policy altReward hPolicy hAlt t) :=
        sequentialTranscript_isProbability policy altReward hPolicy hAlt t
      letI : IsMarkovKernel (sequentialStepKernel policy baseReward hPolicy hBase t) :=
        sequentialStepKernel_isMarkov policy baseReward hPolicy hBase t
      letI : IsMarkovKernel (sequentialStepKernel policy altReward hPolicy hAlt t) :=
        sequentialStepKernel_isMarkov policy altReward hPolicy hAlt t
      rw [sequentialTranscript, sequentialTranscript,
        InformationTheory.klDiv_compProd_eq_add, ih]
      simp [sequentialLocalKL, Finset.sum_range_succ]

end BudgetFreeBandits
