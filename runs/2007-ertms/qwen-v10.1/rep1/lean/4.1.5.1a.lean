import ContractForge
open ContractForge

-- 4.1.5.1a: Transferring to Full Supervision shall occur automatically when a movement authority and all other necessary information is received through track-to-train transmission.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  movementAuthorityReceived : Bool
  allNecessaryInfoReceived  : Bool
  deriving DecidableEq, Repr

structure Output where
  inFullSupervision : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.movementAuthorityReceived ∧ i.allNecessaryInfoReceived
  post := fun i o => o.inFullSupervision = true

example : Spec.pre { movementAuthorityReceived := true, allNecessaryInfoReceived := true } ∧
          Spec.post { movementAuthorityReceived := true, allNecessaryInfoReceived := true }
                    { inFullSupervision := true } := by
  unfold Spec; decide
