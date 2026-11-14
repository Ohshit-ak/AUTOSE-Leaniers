import ContractForge
open ContractForge

-- 5.2.3.41: 5.2.3.41 It should be possible for the driver to store and overwrite numbers and their details in the Cab radio. (O) Invoke supplementary services

-- L0 spec

structure Input where
  number  : Nat
  details : String
  deriving DecidableEq, Repr

structure Output where
  number  : Nat
  details : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.number = i.number ∧
                     (o.details = i.details ∨
                      (o.number ≠ i.number ∧ o.details = "Overwritten"))

example : Spec.pre { number := 5, details := "Test details" } ∧ Spec.post { number := 5, details := "Test details" } { number := 5, details := "Test details" } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { number := x.number,
    details := if x.number = x.number ∧ x.details = "Overwritten" then "Overwritten" else x.details }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
