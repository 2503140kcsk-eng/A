module

public import BudgetFreeBandits.PointSpikeLocalKL
public import Mathlib.Algebra.Order.BigOperators.Ring.Finset

noncomputable section

namespace BudgetFreeBandits

/--
Within a gap of real length x, the sum of the missed post-change rounds is
x(x+1)/2. This is at least x^2/2 for every nonnegative gap length.
-/
theorem pointSpike_gap_triangle_lower
    {ι : Type*} (gaps : Finset ι) (gap : ι → ℝ) (scale : ℝ)
    (hscale : 0 ≤ scale)
    (hgap : ∀ i ∈ gaps, 0 ≤ gap i) :
    scale / 2 * (∑ i ∈ gaps, gap i ^ 2) ≤
      scale * (∑ i ∈ gaps, gap i * (gap i + 1) / 2) := by
  have hsum :
      (∑ i ∈ gaps, gap i ^ 2) / 2 ≤
        ∑ i ∈ gaps, gap i * (gap i + 1) / 2 := by
    rw [← Finset.sum_div]
    apply Finset.sum_le_sum
    intro i hi
    have hnonneg := hgap i hi
    nlinarith [sq_nonneg (gap i)]
  calc
    scale / 2 * (∑ i ∈ gaps, gap i ^ 2)
      = scale * ((∑ i ∈ gaps, gap i ^ 2) / 2) := by ring
    _ ≤ scale * (∑ i ∈ gaps, gap i * (gap i + 1) / 2) :=
      mul_le_mul_of_nonneg_left hsum hscale

/--
Arm-averaging step for the point-spike lower bound.  Titu's lemma
(squared-sum divided by the sum of positive weights) replaces the convexity /
Jensen step. The hypotheses state that the total number of target-arm pulls
is at most both half the total available opportunities and the baseline
regret divided by the baseline gap.
-/
theorem pointSpike_arm_gap_average_lower
    {ι : Type*} (arms : Finset ι) (pulls : ι → ℝ)
    (q r0 gap : ℝ)
    (hq : 0 < q) (hr0 : 0 ≤ r0) (hgap : 0 < gap)
    (hcard : 0 < (arms.card : ℝ))
    (hpulls_nonneg : ∀ i ∈ arms, 0 ≤ pulls i)
    (hpulls_budget :
      (∑ i ∈ arms, pulls i) ≤ r0 / gap)
    (hpulls_half :
      (∑ i ∈ arms, pulls i) ≤ (arms.card : ℝ) * q / 2) :
    gap / (2 * q * (arms.card : ℝ)) *
        (∑ i ∈ arms, (q - pulls i) ^ 2 / (pulls i + 1)) ≥
      gap ^ 2 * (arms.card : ℝ) * q /
        (8 * (r0 + gap * (arms.card : ℝ))) := by
  let n : ℝ := (arms.card : ℝ)
  let M : ℝ := ∑ i ∈ arms, pulls i
  let S : ℝ := ∑ i ∈ arms, (q - pulls i)
  let D : ℝ := ∑ i ∈ arms, (pulls i + 1)
  let R : ℝ := ∑ i ∈ arms, (q - pulls i) ^ 2 / (pulls i + 1)
  have hn : 0 < n := by
    exact hcard
  have hMnonneg : 0 ≤ M := by
    dsimp [M]
    exact Finset.sum_nonneg fun i hi => hpulls_nonneg i hi
  have hsumS : S = n * q - M := by
    dsimp [S, n, M]
    rw [Finset.sum_sub_distrib]
    simp [mul_comm]
  have hsumD : D = M + n := by
    dsimp [D, n, M]
    rw [Finset.sum_add_distrib]
    simp
  have hSbound : n * q / 2 ≤ S := by
    rw [hsumS]
    dsimp [M] at hpulls_half
    nlinarith [hpulls_half, mul_nonneg (le_of_lt hn) (le_of_lt hq)]
  have hDupper : D ≤ r0 / gap + n := by
    rw [hsumD]
    dsimp [M] at hpulls_budget
    exact add_le_add_right hpulls_budget n
  have hDpos : 0 < D := by
    rw [hsumD]
    linarith
  have hUpos : 0 < r0 / gap + n := by
    positivity
  have hRnonneg : 0 ≤ R := by
    dsimp [R]
    apply Finset.sum_nonneg
    intro i hi
    exact div_nonneg (sq_nonneg _) (by linarith [hpulls_nonneg i hi])
  have hTitu : S ^ 2 / D ≤ R := by
    dsimp [S, D, R]
    exact Finset.sq_sum_div_le_sum_sq_div arms
      (fun i => q - pulls i)
      (by
        intro i hi
        linarith [hpulls_nonneg i hi])
  have hCS : S ^ 2 ≤ D * R :=
    (div_le_iff₀ hDpos).mp hTitu
  have hnum : 0 ≤ n * q / 2 := by positivity
  have hnumSq : (n * q / 2) ^ 2 ≤ S ^ 2 := by
    nlinarith [hSbound]
  have hDR : D * R ≤ (r0 / gap + n) * R :=
    mul_le_mul_of_nonneg_right hDupper hRnonneg
  have hkey : (n * q / 2) ^ 2 ≤ (r0 / gap + n) * R :=
    le_trans hnumSq (le_trans hCS hDR)
  have hRlower :
      (n * q / 2) ^ 2 / (r0 / gap + n) ≤ R :=
    (div_le_iff₀ hUpos).2 hkey
  have hcoef : 0 ≤ gap / (2 * q * n) := by positivity
  have hscaled := mul_le_mul_of_nonneg_left hRlower hcoef
  have hden : 0 < r0 + gap * n := by positivity
  have halgebra :
      gap / (2 * q * n) * ((n * q / 2) ^ 2 / (r0 / gap + n)) =
        gap ^ 2 * n * q / (8 * (r0 + gap * n)) := by
    field_simp [ne_of_gt hq, ne_of_gt hn, ne_of_gt hgap,
      ne_of_gt hUpos, ne_of_gt hden]
    <;> ring
  rw [← halgebra]
  exact hscaled

end BudgetFreeBandits
