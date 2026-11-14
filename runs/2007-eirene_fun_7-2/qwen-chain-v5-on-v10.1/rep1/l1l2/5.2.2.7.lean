import ContractForge
open ContractForge

-- 5.2.2.7: 5.2.2.7 If the functional identity of the connected party contains an alphanumeric description, this shall also be displayed. (M)

-- L0 spec

structure Input where
  description : String
  deriving DecidableEq, Repr

structure Output where
  displayed : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.description ≠ ""
  post := fun i o => o.displayed = i.description

example : Spec.pre { description := "Cab Radio" } ∧
          Spec.post { description := "Cab Radio" } { displayed := "Cab Radio" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { displayed := x.description }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
