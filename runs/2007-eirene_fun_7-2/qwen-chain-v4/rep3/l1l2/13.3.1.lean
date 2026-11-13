import ContractForge
open ContractForge

-- 13.3.1: 13.3.1 Authorised EIRENE mobiles shall be able to receive a Railway emergency call at any time while the mobile is powered up. (M)

-- L0 spec

structure Input where
  poweredUp : Bool
  deriving DecidableEq, Repr

structure Output where
  received : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.poweredUp
  post := fun i o => o.received = true

example : Spec.pre { poweredUp := true } ∧ Spec.post { poweredUp := true } { received := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { received := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
