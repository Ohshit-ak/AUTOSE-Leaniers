import ContractForge
open ContractForge

-- 5.4.2/S1: Upon switch on, the Cab radio shall be registered with a mobile network (see section 10.5).

-- L0 spec

structure Input where
  cabId : Nat
  networkRegistration : Bool
  deriving DecidableEq, Repr

structure Output where
  cabId : Nat
  networkRegistered : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.networkRegistration = true
  post := fun i o => o.cabId = i.cabId ∧ o.networkRegistered = true

example : Spec.pre { cabId := 123, networkRegistration := true } ∧
          Spec.post { cabId := 123, networkRegistration := true }
                    { cabId := 123, networkRegistered := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { cabId := x.cabId,
    networkRegistered := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
