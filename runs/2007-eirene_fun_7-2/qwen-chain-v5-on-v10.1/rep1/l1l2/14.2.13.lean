import ContractForge
open ContractForge

-- 14.2.13: 14.2.13 It should be possible for the system to record: (O) shunting group composition at a given instant; the source and time a shunting emergency call was transmitted; the recipients of a shunting emergency call.

-- L0 spec

structure ShuntingGroup where
  composition : List String
  deriving DecidableEq, Repr

structure EmergencyCall where
  source : String
  time   : Nat
  recipients : List String
  deriving DecidableEq, Repr

structure Input where
  shuntingGroup : ShuntingGroup
  emergencyCall : Option EmergencyCall
  deriving DecidableEq, Repr

structure Output where
  shuntingGroup : ShuntingGroup
  emergencyCall : Option EmergencyCall
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.shuntingGroup = i.shuntingGroup ∧
                     (o.emergencyCall = i.emergencyCall ∨
                      (o.emergencyCall.isSome ↔ i.emergencyCall.isSome) ∧
                      o.emergencyCall.getD { source := "", time := 0, recipients := [] } =
                      i.emergencyCall.getD { source := "", time := 0, recipients := [] })

example : Spec.pre { shuntingGroup := { composition := ["locomotive", "wagons"] },
                     emergencyCall := some { source := "control room", time := 1500,
                                             recipients := ["engineer", "mechanic"] } } ∧
          Spec.post { shuntingGroup := { composition := ["locomotive", "wagons"] },
                      emergencyCall := some { source := "control room", time := 1500,
                                              recipients := ["engineer", "mechanic"] } }
                    { shuntingGroup := { composition := ["locomotive", "wagons"] },
                      emergencyCall := some { source := "control room", time := 1500,
                                              recipients := ["engineer", "mechanic"] } } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { shuntingGroup := x.shuntingGroup,
    emergencyCall := x.emergencyCall }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
