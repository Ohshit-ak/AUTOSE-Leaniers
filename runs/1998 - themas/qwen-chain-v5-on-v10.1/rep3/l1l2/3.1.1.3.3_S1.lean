import ContractForge
open ContractForge

-- 3.1.1.3.3/S1: The maximum number of heating or cooling units that can run concurrently shall reside in an initialization file.

-- L0 spec

structure HeatingUnit where
  id : Nat
  status : Bool
  deriving DecidableEq, Repr

structure CoolingUnit where
  id : Nat
  status : Bool
  deriving DecidableEq, Repr

structure Input where
  maxConcurrent : Nat
  heatingUnits : List HeatingUnit
  coolingUnits : List CoolingUnit
  deriving DecidableEq, Repr

structure Output where
  maxConcurrent : Nat
  heatingUnits : List HeatingUnit
  coolingUnits : List CoolingUnit
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.heatingUnits.Nodup ∧ i.coolingUnits.Nodup
  post := fun i o => o.maxConcurrent = i.maxConcurrent ∧
                     o.heatingUnits = i.heatingUnits ∧
                     o.coolingUnits = i.coolingUnits

example : Spec.pre { maxConcurrent := 5,
                     heatingUnits := [{ id := 1, status := true }],
                     coolingUnits := [{ id := 2, status := false }] } ∧
          Spec.post { maxConcurrent := 5,
                      heatingUnits := [{ id := 1, status := true }],
                      coolingUnits := [{ id := 2, status := false }] }
                    { maxConcurrent := 5,
                      heatingUnits := [{ id := 1, status := true }],
                      coolingUnits := [{ id := 2, status := false }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { maxConcurrent := x.maxConcurrent,
    heatingUnits := x.heatingUnits,
    coolingUnits := x.coolingUnits }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
