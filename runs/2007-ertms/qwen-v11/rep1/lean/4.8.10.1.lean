import ContractForge
open ContractForge

-- 4.8.10.1: It shall be possible to send information regarding the inhibition of the following different types of brake: Regenerative brake Eddy current brake Magnetic shoe brake
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  brakeType : String
  inhibited : Bool
  deriving DecidableEq, Repr

structure Output where
  brakeType : String
  inhibited : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.brakeType ∈ ["Regenerative brake", "Eddy current brake", "Magnetic shoe brake"]
  post := fun i o => o.brakeType = i.brakeType ∧ o.inhibited = i.inhibited

example : Spec.pre { brakeType := "Regenerative brake", inhibited := true } ∧
          Spec.post { brakeType := "Regenerative brake", inhibited := true }
                     { brakeType := "Regenerative brake", inhibited := true } := by
  unfold Spec; decide
