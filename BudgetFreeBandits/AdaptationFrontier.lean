module

public import Mathlib

/-!
# Algebraic adaptation frontier

This file formalizes an algebraic corollary of Theorem 5.1 in:

Xiaojin Zhang, "Variance-Aware Non-Stationary Bandits: All-Budget Regret Bounds
and Adaptation Costs", arXiv:2610.26116v1 (19 October 2026).

The stochastic bandit model and the information-theoretic proof of Theorem 5.1
are NOT formalized here. The hypotheses hstationary and hchange are exactly
the two inequalities supplied by that theorem. This file proves the numerical
consequence from those inequalities without sorry or additional axioms.
-/

namespace BudgetFreeBandits

/--
Algebraic consequence of the stationary/change-regret inequalities.

Let n = A - 1, q = T - 1, and u = sqrt(n*q).
Theorem 5.1 of arXiv:2610.26116 gives:
* r1 >= r0 - g for every policy;
* if r0 <= g*n*q/2, then
  r1 >= (g^2*n*q) / (8*(r0 + g*n)).

For u^2 = n*q, u >= 4, and n <= u, split into
r0 >= g*u/2 and r0 < g*u/2. In the first branch the stationary
inequality gives the result. In the second branch, r0 < g*u/2 <= g*n*q/2,
so the change-of-measure inequality applies. Its denominator is at most
12*g*u, yielding r1 >= g*u/12.
-/
theorem theorem_5_1_algebraic_corollary
    {g n q u r0 r1 : ℝ}
    (hg : 0 < g)
    (hn : 0 < n)
    (hq : 0 < q)
    (hu : 4 ≤ u)
    (hu_sq : u ^ 2 = n * q)
    (hn_le_u : n ≤ u)
    (hr0_nonneg : 0 ≤ r0)
    (hstationary : r1 ≥ r0 - g)
    (hchange :
      r0 ≤ g * n * q / 2 →
        r1 ≥ (g ^ 2 * n * q) / (8 * (r0 + g * n))) :
    r1 ≥ g * u / 12 := by
  by_cases hlarge : g * u / 2 ≤ r0
  · have hgap : 0 ≤ g * (u - 4) :=
      mul_nonneg (le_of_lt hg) (by linarith)
    have hgu : g ≤ g * u / 4 := by nlinarith [hgap]
    have hmid : g * u / 4 ≤ r0 - g := by linarith
    have hgu_nonneg : 0 ≤ g * u :=
      mul_nonneg (le_of_lt hg) (by linarith)
    have hsmallfactor : g * u / 12 ≤ g * u / 4 := by
      nlinarith [hgu_nonneg]
    exact le_trans hsmallfactor (le_trans hmid hstationary)
  · have hsmall : r0 < g * u / 2 := lt_of_not_ge hlarge
    have hscale : g * u / 2 ≤ g * u ^ 2 / 2 := by
      have hmul : 0 ≤ g * (u ^ 2 - u) :=
        mul_nonneg (le_of_lt hg) (by nlinarith [hu])
      nlinarith [hmul]
    have hcondition_lt : r0 < g * n * q / 2 := by
      calc
        r0 < g * u / 2 := hsmall
        _ ≤ g * u ^ 2 / 2 := hscale
        _ = g * n * q / 2 := by rw [hu_sq]; ring
    have hcondition : r0 ≤ g * n * q / 2 := le_of_lt hcondition_lt
    have hden : 0 < 8 * (r0 + g * n) := by positivity
    have hfactor : 0 ≤ g * u / 12 := by positivity
    have hgn : g * n ≤ g * u :=
      mul_le_mul_of_nonneg_left hn_le_u (le_of_lt hg)
    have hden_bound : 8 * (r0 + g * n) ≤ 12 * g * u := by
      nlinarith [hsmall, hgn]
    have hscaled := mul_le_mul_of_nonneg_left hden_bound hfactor
    have hidentity : (g * u / 12) * (12 * g * u) = g ^ 2 * n * q := by
      calc
        (g * u / 12) * (12 * g * u) = g ^ 2 * u ^ 2 := by ring
        _ = g ^ 2 * (n * q) := by rw [hu_sq]
        _ = g ^ 2 * n * q := by ring
    have hmul :
        (g * u / 12) * (8 * (r0 + g * n)) ≤ g ^ 2 * n * q := by
      nlinarith [hscaled, hidentity]
    have hratio :
        g * u / 12 ≤ (g ^ 2 * n * q) / (8 * (r0 + g * n)) :=
      (le_div_iff₀ hden).2 hmul
    exact le_trans hratio (hchange hcondition)

end BudgetFreeBandits
