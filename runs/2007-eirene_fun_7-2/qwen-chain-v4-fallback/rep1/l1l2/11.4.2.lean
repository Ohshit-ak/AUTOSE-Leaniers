import ContractForge
open ContractForge

-- 11.4.2: 11.4.2 The functions to which calls shall be routed based upon the location of the mobile shall include: (M) Primary controller; Secondary controller; Power supply controller; Train management centre (eg RBC, CTS).

-- L0 spec

structure Input where
  location : String
  deriving DecidableEq, Repr

structure Output where
  controller : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.location ≠ ""
  post := fun i o => o.controller = "Primary controller" ∨
                     o.controller = "Secondary controller" ∨
                     o.controller = "Power supply controller" ∨
                     o.controller = "Train management centre (eg RBC, CTS)"

example : Spec.pre { location := "primary" } ∧
          Spec.post { location := "primary" }
                    { controller := "Primary controller" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { controller := if x.location = "" then "Invalid input" else "Primary controller" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
