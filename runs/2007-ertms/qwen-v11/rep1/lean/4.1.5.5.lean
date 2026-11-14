import ContractForge
open ContractForge

-- 4.1.5.5: The trainborne equipment shall remain in Full Supervision until the trainborne equipment is not active any longer, when Shunting is selected or when Partial Supervision information is received.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  active : Bool
  shuntingSelected : Bool
  partialSupervisionInfoReceived : Bool
  fullSupervision : Bool
  deriving DecidableEq, Repr

structure Output where
  fullSupervision : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.active
  post := fun i o => o.fullSupervision ↔
    (¬i.shuntingSelected ∧ ¬i.partialSupervisionInfoReceived) ∨
    (i.shuntingSelected ∨ i.partialSupervisionInfoReceived) ∧
    (o.fullSupervision = i.fullSupervision ↔
     (i.shuntingSelected ∨ i.partialSupervisionInfoReceived))

example : Spec.pre { active := true, shuntingSelected := false, partialSupervisionInfoReceived := false, fullSupervision := true } ∧
          Spec.post { active := true, shuntingSelected := false, partialSupervisionInfoReceived := false, fullSupervision := true }
                    { fullSupervision := true } := by
  unfold Spec; decide
