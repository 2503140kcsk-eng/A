import Lake
open Lake DSL

package «budget-free-bandits» where
  version := v!"0.1.0"

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "v4.36.0-rc2"

lean_lib BudgetFreeBandits
