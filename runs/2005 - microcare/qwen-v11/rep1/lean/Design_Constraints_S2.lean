import ContractForge
open ContractForge

-- Design Constraints/S2: All the level of details will have a master table in order to update as per the program requirements.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  distributorId : Nat
  voucherDetails : String
  deriving DecidableEq, Repr

structure Output where
  updated : Bool
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.distributorId ≠ 0 ∧ i.voucherDetails ≠ ""
  post := fun i o => o.updated = true ∧
    (o.message = "Distributor master information updated successfully." ↔
     i.voucherDetails ≠ "new details") ∧
    (o.message = "No changes needed." ↔
     i.voucherDetails = "new details")

example : Spec.pre { distributorId := 1, voucherDetails := "current details" } ∧ Spec.post { distributorId := 1, voucherDetails := "current details" } { updated := true, message := "Distributor master information updated successfully." } := by
  unfold Spec; decide
