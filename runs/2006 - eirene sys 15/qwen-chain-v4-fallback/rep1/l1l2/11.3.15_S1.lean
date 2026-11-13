import ContractForge
open ContractForge

-- 11.3.15/S1: Deregistration of a functional number shall not be carried out until registration of the functional number has been carried out and confirmed as being successful.

-- L0 spec

structure FunctionalNumber where
  id : Nat
  status : String
  deriving DecidableEq, Repr

structure Input where
  deregistered : Nat
  registered   : Nat
  status       : String
  deriving DecidableEq, Repr

structure Output where
  deregistered : Nat
  registered    : Nat
  status        : String
  success       : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.status = "registered" ∧ i.registered ≠ 0
  post := fun i o => (o.success = true ↔ i.deregistered = i.registered) ∧
                     (o.success = false → o.deregistered = i.deregistered ∧ o.registered = i.registered)

example : Spec.pre { deregistered := 0, registered := 1, status := "registered" } ∧ Spec.post { deregistered := 0, registered := 1, status := "registered" } { deregistered := 0, registered := 1, status := "deregistered", success := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { deregistered := x.deregistered,
    registered := x.registered,
    status := "deregistered",
    success := x.deregistered = x.registered }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
