import ContractForge
open ContractForge

-- 14.4.3/S1: The terminal application shall prevent members of a dedicated shunting team from initiating a new call (unless they are registered as shunting team leader and have left shunting mode using the "maintain group call" function described in 14.2.4).
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  shuntingTeamLeader : Bool
  inShuntingMode     : Bool
  initiatingCall     : Bool
  deriving DecidableEq, Repr

structure Output where
  allowedToInitiate : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.initiatingCall = true
  post := fun i o => (o.allowedToInitiate = true ↔
    (i.shuntingTeamLeader = true ∧ i.inShuntingMode = false)) ∨
    (o.allowedToInitiate = false ↔
    (i.shuntingTeamLeader = false ∨ i.inShuntingMode = true))

example : Spec.pre { shuntingTeamLeader := false, inShuntingMode := true, initiatingCall := true } ∧
          Spec.post { shuntingTeamLeader := false, inShuntingMode := true, initiatingCall := true }
                    { allowedToInitiate := false } := by
  unfold Spec; decide
