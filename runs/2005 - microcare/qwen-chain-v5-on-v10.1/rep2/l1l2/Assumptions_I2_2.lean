import ContractForge
open ContractForge

-- Assumptions/I2#2: The user will not alter any information about treatment, which is populating from the system

-- L0 spec

structure Treatment where
  id     : Nat
  name   : String
  details: String
  deriving DecidableEq, Repr

structure Input where
  treatments : List Treatment
  deriving DecidableEq, Repr

structure Output where
  treatments : List Treatment
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.treatments = i.treatments

example : Spec.pre { treatments := [{ id := 1, name := "Treatment A", details := "Details A" },
                                     { id := 2, name := "Treatment B", details := "Details B" }] } ∧
          Spec.post { treatments := [{ id := 1, name := "Treatment A", details := "Details A" },
                                      { id := 2, name := "Treatment B", details := "Details B" }] }
                    { treatments := [{ id := 1, name := "Treatment A", details := "Details A" },
                                     { id := 2, name := "Treatment B", details := "Details B" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { treatments := x.treatments }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
