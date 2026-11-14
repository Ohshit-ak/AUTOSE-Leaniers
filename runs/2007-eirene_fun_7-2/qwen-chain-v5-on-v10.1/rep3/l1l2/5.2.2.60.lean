import ContractForge
open ContractForge

-- 5.2.2.60: 5.2.2.60 The Cab radio shall provide a means for the driver to terminate calls which he is authorised to terminate (ie all calls except Railway emergency calls not initiated by the driver and shunting group calls). (M)

-- L0 spec

structure Call where
  initiatedByDriver : Bool
  railwayEmergency : Bool
  shuntingGroupCall : Bool
  deriving DecidableEq, Repr

structure Input where
  calls : List Call
  deriving DecidableEq, Repr

structure Output where
  terminated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.calls.length > 0
  post := fun i o => o.terminated = true ↔
    ∃ c ∈ i.calls, c.initiatedByDriver ∧ ¬c.railwayEmergency ∧ ¬c.shuntingGroupCall

example : Spec.pre { calls := [{ initiatedByDriver := true, railwayEmergency := false, shuntingGroupCall := false },
                                { initiatedByDriver := false, railwayEmergency := true, shuntingGroupCall := false },
                                { initiatedByDriver := true, railwayEmergency := false, shuntingGroupCall := true }] } ∧
          Spec.post { calls := [{ initiatedByDriver := true, railwayEmergency := false, shuntingGroupCall := false },
                                 { initiatedByDriver := false, railwayEmergency := true, shuntingGroupCall := false },
                                 { initiatedByDriver := true, railwayEmergency := false, shuntingGroupCall := true }] }
                    { terminated := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { terminated := decide (∃ c ∈ x.calls, c.initiatedByDriver ∧ ¬c.railwayEmergency ∧ ¬c.shuntingGroupCall) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
