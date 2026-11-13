import ContractForge
open ContractForge

-- 5.2.2.60: 5.2.2.60 The Cab radio shall provide a means for the driver to terminate calls which he is authorised to terminate (ie all calls except Railway emergency calls not initiated by the driver and shunting group calls). (M)
-- compiles: True · rejects_bad_example: True · checked: True

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
