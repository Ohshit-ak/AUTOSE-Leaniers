import ContractForge
open ContractForge

-- 13.5.7/S1: Confirmation messages shall be sent to a confirmation centre using a defined short code (see table 9-10), which shall be associated with the GSM network.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  shortCode : String
  deriving DecidableEq, Repr

structure Output where
  confirmed : Bool
  message   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.shortCode.length = 4 ∧
                  i.shortCode.toList.all Char.isDigit = true
  post := fun i o => (o.confirmed = true ↔ i.shortCode = "1122") ∧
                     (o.confirmed = false → o.message = "Invalid short code")

example : Spec.pre { shortCode := "1122" } ∧
          Spec.post { shortCode := "1122" }
                    { confirmed := true, message := "" } := by
  unfold Spec; decide
