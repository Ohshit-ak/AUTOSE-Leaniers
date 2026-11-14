import ContractForge
open ContractForge

-- 7.2.3.13: 7.2.3.13 It shall be possible for the user to store and/or overwrite numbers and their details in the radio. (M) Computer interface

-- L0 spec

structure Input where
  number : Nat
  details : String
  deriving DecidableEq, Repr

structure Output where
  stored : Bool
  newNumber : Nat
  newDetails : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.stored = true ∧
                     (o.newNumber = i.number ∨ o.newNumber ≠ i.number) ∧
                     (o.newDetails = i.details ∨ o.newDetails ≠ i.details) ∧
                     (o.newNumber = i.number ↔ o.stored) ∧
                     (o.newDetails = i.details ↔ o.stored)

example : Spec.pre { number := 123, details := "details123" } ∧
          Spec.post { number := 123, details := "details123" }
                    { stored := true, newNumber := 123, newDetails := "details123" } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { stored := true,
    newNumber := x.number,
    newDetails := x.details }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
