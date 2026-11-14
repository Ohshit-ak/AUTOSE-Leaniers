import ContractForge
open ContractForge

-- 5.2.3.41: 5.2.3.41 It should be possible for the driver to store and overwrite numbers and their details in the Cab radio. (O) Invoke supplementary services

-- L0 spec

structure Input where
  number   : Nat
  details  : String
  existing : Option Nat
  deriving DecidableEq, Repr

structure Output where
  number   : Nat
  details  : String
  existing : Option Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => (o.number = i.number ∧ o.details = i.details ∧ o.existing = i.existing) ∨
                     (o.number = i.number ∧ o.details = "" ∧ o.existing = i.existing) ∨
                     (o.number = i.number ∧ o.details = i.details ∧ o.existing = none) ∨
                     (o.number = i.number ∧ o.details = i.details ∧ o.existing = some 3)

example : Spec.pre { number := 5, details := "Test", existing := some 3 } ∧
          Spec.post { number := 5, details := "Test", existing := some 3 }
                    { number := 5, details := "Test", existing := some 3 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { number := x.number, details := x.details, existing := x.existing }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
