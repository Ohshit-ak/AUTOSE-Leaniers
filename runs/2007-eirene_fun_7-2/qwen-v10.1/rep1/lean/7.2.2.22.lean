import ContractForge
open ContractForge

-- 7.2.2.22: 7.2.2.22 If the user moves out of the group or broadcast call area whilst the call is in progress, an audible and visual indication of the loss of call shall be provided to the user. (M) Receive incoming Railway emergency call
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  userPosition : String
  callActive   : Bool
  callArea     : String
  deriving DecidableEq, Repr

structure Output where
  userPosition : String
  callActive   : Bool
  callArea     : String
  alert        : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callActive = true
  post := fun i o => (o.alert = true ↔
    (i.userPosition ≠ i.callArea ∧ i.callActive = true))

example : Spec.pre { userPosition := "outside", callActive := true, callArea := "inside" } ∧
          Spec.post { userPosition := "outside", callActive := true, callArea := "inside" }
                    { userPosition := "outside", callActive := true, callArea := "inside", alert := true } := by
  unfold Spec; decide
