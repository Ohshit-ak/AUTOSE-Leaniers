import ContractForge
open ContractForge

-- 3.1.4.1.3/S2: To clarify these conditions, the following definitions will be used: LO : Lower Overtemperature Value = TSET - OD UO : Upper Overtemperature Value = TSET + OD If T = LO or UO = T then the THEMAS system shall recognize this condition as the temperature limit has been exceeded.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  TSET : Nat
  OD   : Nat
  T    : Nat
  deriving DecidableEq, Repr

structure Output where
  exceeded : Bool
  deriving DecidableEq, Repr

def LO (i : Input) : Nat := i.TSET - i.OD
def UO (i : Input) : Nat := i.TSET + i.OD

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.exceeded = true ↔ (i.T = LO i) ∨ (i.T = UO i)

example : Spec.pre { TSET := 100, OD := 10, T := 110 } ∧ Spec.post { TSET := 100, OD := 10, T := 110 } { exceeded := true } := by
  unfold Spec; decide
