import ContractForge
open ContractForge

-- 4.1.5.5: The trainborne equipment shall remain in Full Supervision until the trainborne equipment is not active any longer, when Shunting is selected or when Partial Supervision information is received.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  active : Bool
  shuntingSelected : Bool
  partialSupervisionInfoReceived : Bool
  deriving DecidableEq, Repr

structure Output where
  fullSupervision : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.active
  post := fun i o => (o.fullSupervision = true ↔ i.active) ∧
                     (o.fullSupervision = false ↔
                      (i.shuntingSelected ∧ i.active) ∨
                      (i.partialSupervisionInfoReceived ∧ i.active))

example : Spec.pre { active := true, shuntingSelected := false, partialSupervisionInfoReceived := false } ∧ Spec.post { active := true, shuntingSelected := false, partialSupervisionInfoReceived := false } { fullSupervision := true } := by
  unfold Spec; decide
