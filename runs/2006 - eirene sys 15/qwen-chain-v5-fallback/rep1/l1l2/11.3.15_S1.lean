import ContractForge
open ContractForge

-- 11.3.15/S1: Deregistration of a functional number shall not be carried out until registration of the functional number has been carried out and confirmed as being successful.

-- L0 spec

structure FunctionalNumber where
  number : Nat
  registered : Bool
  deriving DecidableEq, Repr

structure Input where
  number : Nat
  registered : Bool
  deriving DecidableEq, Repr

structure Output where
  deregistered : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.registered
  post := fun i o => o.deregistered = false ∧
                     (o.deregistered = true ↔ i.registered = false)

example : Spec.pre { number := 123, registered := true } ∧
          Spec.post { number := 123, registered := true }
                    { deregistered := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { deregistered := false }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
