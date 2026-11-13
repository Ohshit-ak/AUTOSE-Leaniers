import ContractForge
open ContractForge

-- 11.2.1.9: 11.2.1.9 The functional addressing scheme shall be independent of specific configurations of mobile and terminal equipment. For example, the functional number of a conductor on board a particular train shall be the same irrespective of whether the conductor accesses the network through the Cab radio or has a separate dedicated EIRENE mobile. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  conductorFunctionalNumber : String
  accessMethod              : String
  deriving DecidableEq, Repr

structure Output where
  functionalNumber : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.conductorFunctionalNumber ≠ "" ∧
                  (i.accessMethod = "Cab radio" ∨ i.accessMethod = "Dedicated EIRENE mobile")
  post := fun i o => o.functionalNumber = i.conductorFunctionalNumber

example : Spec.pre { conductorFunctionalNumber := "12345", accessMethod := "Cab radio" } ∧
          Spec.post { conductorFunctionalNumber := "12345", accessMethod := "Cab radio" }
                    { functionalNumber := "12345" } := by
  unfold Spec; decide
