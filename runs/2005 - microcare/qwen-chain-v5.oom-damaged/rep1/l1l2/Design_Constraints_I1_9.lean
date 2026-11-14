import ContractForge
open ContractForge

-- Design Constraints/I1#9: The system admin only can able to create User Groups

-- L0 spec

structure Input where
  admin : Bool
  deriving DecidableEq, Repr

structure Output where
  created : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.admin
  post := fun i o => o.created = true

example : Spec.pre { admin := true } ∧ Spec.post { admin := true } { created := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { created := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
