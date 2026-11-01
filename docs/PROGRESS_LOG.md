# Progress log

## 2026-11-01 — research project initialized

### Completed
- Confirmed 2503140kcsk-eng/A is public and the connected GitHub account has admin/push permission.
- Created branch research/budget-free-variance-aware-bandits.
- Changed the README title and project mission.
- Read the 19 October 2026 target preprint and recorded its distinction between supplied-budget minimax optimality and the still-open prior-free noisy adaptation problem.
- Audited the target paper's related-work exclusions: prior deterministic unknown-variation adaptation already exists; the gap is not merely “unknown variation.”
- Added formal model, literature boundaries, roadmap, and roles for the requested mathematical repositories.
- Added a Lean project pinned to matching Mathlib/Lean release.
- Added a Lean theorem intended to derive r1 >= gu/12 from the two inequalities in Theorem 5.1.

### Not yet verified
- Lean compilation and CI execution have not yet been confirmed.
- The stochastic bandit model and information-theoretic proof of Theorem 5.1 are not yet formalized.
- No new theorem for unrestricted noisy unknown-budget adaptation has been proved.
- No algorithm has been demonstrated to attain the optimal prior-free profile.

### Next required evidence
1. Successful GitHub Actions Lean build for the exact commit.
2. Line-by-line audit of formal assumptions against Theorem 5.1.
3. Separately reviewed proof or counterexample for unrestricted noisy adaptation.
