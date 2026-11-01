import Lake
open Lake DSL

package budgetFreeBandits where
  version := v!"0.1.0"
  requiresModuleSystem := true

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "v4.36.0-rc2"

@[default_target]
lean_lib BudgetFreeBandits
