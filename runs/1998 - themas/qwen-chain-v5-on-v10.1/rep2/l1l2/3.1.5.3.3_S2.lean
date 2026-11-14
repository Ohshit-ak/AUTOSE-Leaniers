import ContractForge
open ContractForge

-- 3.1.5.3.3/S2: This request shall include the designation of the heating or cooling unit and a flag to indicate whether that unit is to be turned on or off.

-- L0 spec

structure HeatingCoolingUnit where
  designation : String
  on          : Bool
  deriving DecidableEq, Repr

structure Input where
  designation : String
  on          : Bool
  deriving DecidableEq, Repr

structure Output where
  designation : String
  on          : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.designation = i.designation ∧ o.on = i.on

example : Spec.pre { designation := "HVAC123", on := true } ∧
          Spec.post { designation := "HVAC123", on := true }
                    { designation := "HVAC123", on := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { designation := x.designation,
    on := x.on }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
