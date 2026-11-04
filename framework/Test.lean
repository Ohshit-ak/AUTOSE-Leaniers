import ContractForge
open ContractForge

-- Smoke test: a tiny contract discharged by `discharge_po`.
def incC : Contract Nat Nat := { pre := fun _ => True, post := fun x y => y > x }

theorem inc_ok : incC.Satisfies (· + 1) := by
  unfold incC; discharge_po

-- String helpers (ContractForge/Strings.lean): one valid and one invalid value each.
example : allDigits "0123".toList = true := by decide
example : allDigits "12a".toList = false := by decide
example : allAlnum "ab12".toList = true := by decide
example : allAlnum "ab-1".toList = false := by decide
example : lenBetween 2 4 "abc".toList = true := by decide
example : lenBetween 2 4 "abcde".toList = false := by decide
example : splitOn '/' "12/31".toList = ["12".toList, "31".toList] := by decide
example : (splitOn '/' "1231".toList).length = 1 := by decide
example : twoDigitNat "07".toList = some 7 := by decide
example : twoDigitNat "7".toList = none := by decide
example : isMMYY "12/27".toList = true := by decide
example : isMMYY "13/27".toList = false := by decide
example : isMMDDYYYY "02/29/2024".toList = true := by decide
example : isMMDDYYYY "02-29-2024".toList = false := by decide
example : isMMDDYYYY "00/10/2024".toList = false := by decide

-- A spec using a helper checks with `decide`, as the spec agent's examples do.
structure DateIn where
  raw : String
  deriving DecidableEq, Repr

def dateOk : Contract DateIn Bool := { pre := fun _ => True, post := fun i v => (v = true ↔ isMMYY i.raw.toList = true) }
example : dateOk.pre { raw := "01/30" } ∧ dateOk.post { raw := "01/30" } true := by
  unfold dateOk; decide

-- Chains (ContractForge/Chain.lean): PO1 of consecutive components gives PO1 of the chain.
example : Contract.Compatible (incC.seq incC) incC :=
  Contract.compat_seq (by unfold incC; discharge_po) (by unfold incC; discharge_po)
