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
  pre  := fun i => True
  post := fun i o => o.mttrAchieved ≥ i.mttrSpec

example : Spec.pre { mttrSpec := 1000 } ∧
          Spec.post { mttrSpec := 1000 } { mttrAchieved := 1200 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { mttrAchieved := x.mttrSpec }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
