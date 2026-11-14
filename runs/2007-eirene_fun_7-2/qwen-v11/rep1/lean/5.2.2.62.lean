import ContractForge
open ContractForge

-- 5.2.2.62: 5.2.2.62 The Cab radio system shall be able to receive incoming text messages (see section 12 for details). (M) Enter/leave shunting mode
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  shuntingMode : Bool
  deriving DecidableEq, Repr

structure Output where
  shuntingMode : Bool
  message      : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.shuntingMode = true
  post := fun i o => o.shuntingMode = false ∧
                     (o.message = "Shunting mode exited." ↔ o.shuntingMode = false)

example : Spec.pre { shuntingMode := true } ∧
          Spec.post { shuntingMode := true }
                    { shuntingMode := false, message := "Shunting mode exited." } := by
  unfold Spec; decide
