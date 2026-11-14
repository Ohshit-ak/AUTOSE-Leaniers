import ContractForge
open ContractForge

-- 5.6.2/S1: As a train approaches the limits of the coverage of the PLMN it is registered with, it will be necessary for it to register with the next PLMN providing coverage.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  currentPlmn : String
  nextPlmn    : String
  deriving DecidableEq, Repr

structure Output where
  registered : Bool
  newPlmn    : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.currentPlmn ≠ "" ∧ i.nextPlmn ≠ ""
  post := fun i o => (o.registered = true ↔ i.currentPlmn = i.nextPlmn) ∧
                     (o.registered = false → o.newPlmn = i.nextPlmn)

example : Spec.pre { currentPlmn := "PLMN1", nextPlmn := "PLMN2" } ∧
          Spec.post { currentPlmn := "PLMN1", nextPlmn := "PLMN2" }
                    { registered := false, newPlmn := "PLMN2" } := by
  unfold Spec; decide
