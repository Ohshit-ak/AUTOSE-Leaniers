import ContractForge
open ContractForge

-- Design Constraints/I1: The voucher will be created ONLY by the authorized person.

-- L0 spec

structure Input where
  creator : String
  authorized : Bool
  deriving DecidableEq, Repr

structure Output where
  created : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.authorized
  post := fun i o => o.created = i.authorized

example : Spec.pre { creator := "Alice", authorized := true } ∧
          Spec.post { creator := "Alice", authorized := true }
                    { created := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { created := x.authorized }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
