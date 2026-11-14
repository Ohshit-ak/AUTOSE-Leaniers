import ContractForge
open ContractForge

-- 5.2.1.2c: In ETCS with RBC this restriction on performance shall, if possible be transmitted to the RBC.

-- L0 spec

structure Input where
  equipmentFailure : Bool
  performanceRestriction : String
  deriving DecidableEq, Repr

structure Output where
  transmittedToRBC : Bool
  performanceStatus : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.equipmentFailure = true
  post := fun i o => (o.transmittedToRBC = true ↔
    i.performanceRestriction ≠ "" ∧
    (o.performanceStatus = "transmitted" ↔
      o.transmittedToRBC = true)) ∧
    (o.transmittedToRBC = false →
      o.performanceStatus = "not transmitted")

example : Spec.pre { equipmentFailure := true, performanceRestriction := "speed limit" } ∧
          Spec.post { equipmentFailure := true, performanceRestriction := "speed limit" }
                    { transmittedToRBC := true, performanceStatus := "transmitted" } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { transmittedToRBC := x.performanceRestriction ≠ "", 
    performanceStatus := if x.performanceRestriction ≠ "" then "transmitted" else "not transmitted" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
