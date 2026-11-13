import ContractForge
open ContractForge

-- 13.5.7/S1: Confirmation messages shall be sent to a confirmation centre using a defined short code (see table 9-10), which shall be associated with the GSM network.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  shortCode : String
  network   : String
  deriving DecidableEq, Repr

structure Output where
  confirmationSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.shortCode.length = 4 ∧
                  i.shortCode.toList.all Char.isDigit = true ∧
                  i.network ≠ ""
  post := fun i o => o.confirmationSent = true ↔
                     (i.shortCode = "1122" ∧ i.network = "GSM")

example : Spec.pre { shortCode := "1122", network := "GSM" } ∧
          Spec.post { shortCode := "1122", network := "GSM" }
                    { confirmationSent := true } := by
  unfold Spec; decide
