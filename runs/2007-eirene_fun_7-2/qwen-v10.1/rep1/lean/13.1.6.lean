import ContractForge
open ContractForge

-- 13.1.6: 13.1.6 The Train emergency call shall be sent to all drivers and controller(s) within an area, which is pre-defined to meet operational requirements. The predefined areas for emergency calls shall include, where necessary, parts of one or more network(s). (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Area where
  network : String
  part    : String
  deriving DecidableEq, Repr

structure Input where
  predefinedAreas : List Area
  deriving DecidableEq, Repr

structure Output where
  driversNotified : Bool
  controllersNotified : Bool
  areaNotified : Area
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.predefinedAreas.Nodup
  post := fun i o => (o.driversNotified = true ∧ o.controllersNotified = true) ↔
    (∃ a ∈ i.predefinedAreas, a.network = o.areaNotified.network ∧ a.part = o.areaNotified.part)

example : Spec.pre { predefinedAreas := [{ network := "network1", part := "part1" },
                                          { network := "network2", part := "part2" }] } ∧
          Spec.post { predefinedAreas := [{ network := "network1", part := "part1" },
                                           { network := "network2", part := "part2" }] }
                    { driversNotified := true, controllersNotified := true, areaNotified := { network := "network1", part := "part1" } } := by
  unfold Spec; decide
