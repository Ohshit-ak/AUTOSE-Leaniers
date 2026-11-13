import ContractForge
open ContractForge

-- 3.11.3/S1: The TCS maintainability will be considered in every phase of the design and development process and shall achieve a system maintainability (Mean Time To Repair MTTR) equal to or greater than that which is specified in the Predator and Outrider ORDs. [SSS411] The Design features shall be included to: [SSS412]
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  mttrSpec : Nat
  deriving DecidableEq, Repr

structure Output where
  mttrAchieved : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.mttrAchieved ≥ i.mttrSpec

example : Spec.pre { mttrSpec := 1000 } ∧
          Spec.post { mttrSpec := 1000 } { mttrAchieved := 1200 } := by
  unfold Spec; decide
