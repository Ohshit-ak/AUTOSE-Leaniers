import ContractForge
open ContractForge

-- 13.1.7: 13.1.7 The Shunting emergency call shall be sent to all users involved in shunting operations in the shunting area. (M)
-- compiles: True · rejects_bad_example: None · checked: True

structure User where
  name : String
  deriving DecidableEq, Repr

structure Input where
  shuntingAreaUsers : List User
  deriving DecidableEq, Repr

structure Output where
  emergencyCallSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.shuntingAreaUsers.Nodup ∧ i.shuntingAreaUsers.all (·.name ≠ "")
  post := fun i o => o.emergencyCallSent = true ∧
                     (∀ u ∈ i.shuntingAreaUsers, u.name ≠ "")

example : Spec.pre { shuntingAreaUsers := [{ name := "John" }, { name := "Jane" }] } ∧
          Spec.post { shuntingAreaUsers := [{ name := "John" }, { name := "Jane" }] }
                    { emergencyCallSent := true } := by
  unfold Spec; decide

def computeEmergencyCallSent (i : Input) : Bool :=
  i.shuntingAreaUsers.Nodup ∧ i.shuntingAreaUsers.all (·.name ≠ "")

example : computeEmergencyCallSent { shuntingAreaUsers := [{ name := "John" }, { name := "Jane" }] } = true := by
  decide
