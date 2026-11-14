import ContractForge
open ContractForge

-- 3.11.3/S1: The TCS maintainability will be considered in every phase of the design and development process and shall achieve a system maintainability (Mean Time To Repair MTTR) equal to or greater than that which is specified in the Predator and Outrider ORDs. [SSS411] The Design features shall be included to: [SSS412]

-- L0 spec

structure Input where
  mttrSpec : Nat
  deriving DecidableEq, Repr

structure Output where
  mttrAchieved : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mttrSpec > 0
  post := fun i o => o.mttrAchieved ≥ i.mttrSpec ∧
                     (o.mttrAchieved = i.mttrSpec →
                      (∀ x < i.mttrSpec, x ≥ 0) ∧
                      (∀ x < i.mttrSpec, x ≤ 1000)) ∧
                     (o.mttrAchieved > i.mttrSpec →
                      (∃ x < i.mttrSpec, x > 0) ∧
                      (∃ x < i.mttrSpec, x ≤ 1000))

example : Spec.pre { mttrSpec := 120 } ∧
          Spec.post { mttrSpec := 120 } { mttrAchieved := 120 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { mttrAchieved := x.mttrSpec }
