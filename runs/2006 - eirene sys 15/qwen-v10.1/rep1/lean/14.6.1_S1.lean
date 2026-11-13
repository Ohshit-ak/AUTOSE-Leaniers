import ContractForge
open ContractForge

-- 14.6.1/S1: Users shall be prevented from joining a dedicated shunting group by the EIRENE terminal application unless a valid functional number for the group has been successfully registered to the GSM-R network by their terminal.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  functionalNumber : String
  isRegistered     : Bool
  groupMembers     : List String
  deriving DecidableEq, Repr

structure Output where
  joinedGroup      : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.isRegistered
  post := fun i o => o.joinedGroup ↔
    (i.functionalNumber ≠ "" ∧
     ∃ gn ∈ i.groupMembers, gn = i.functionalNumber)

example : Spec.pre { functionalNumber := "123456", isRegistered := true,
                     groupMembers := ["123456", "654321"] } ∧
          Spec.post { functionalNumber := "123456", isRegistered := true,
                      groupMembers := ["123456", "654321"] }
                    { joinedGroup := true } := by
  unfold Spec; decide
