import ContractForge
open ContractForge

-- Smoke test: a tiny contract discharged by `discharge_po`.
def incC : Contract Nat Nat := { pre := fun _ => True, post := fun x y => y > x }

theorem inc_ok : incC.Satisfies (· + 1) := by
  unfold incC; discharge_po
