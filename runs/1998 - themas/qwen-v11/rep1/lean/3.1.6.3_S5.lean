import ContractForge
open ContractForge

-- 3.1.6.3/S5: In order to provide an operational history and statistical reports, this process shall generate an event each time a change is made to the status of a heating or cooling unit.
-- compiles: True · rejects_bad_example: True · checked: True

structure StatusChange where
  unitId : Nat
  status : String
  timestamp : Nat
  deriving DecidableEq, Repr

structure Input where
  units : List StatusChange
  deriving DecidableEq, Repr

structure Output where
  events : List StatusChange
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.units.length > 0
  post := fun i o => o.events.length = i.units.length ∧
                     (∀ j ∈ i.units, ∃ e ∈ o.events, e.unitId = j.unitId ∧ e.status = j.status ∧ e.timestamp = j.timestamp) ∧
                     (∀ e ∈ o.events, ∃ j ∈ i.units, e.unitId = j.unitId ∧ e.status = j.status ∧ e.timestamp = j.timestamp)

example : Spec.pre { units := [{ unitId := 1, status := "on", timestamp := 100 },
                                { unitId := 2, status := "off", timestamp := 200 }] } ∧
          Spec.post { units := [{ unitId := 1, status := "on", timestamp := 100 },
                                 { unitId := 2, status := "off", timestamp := 200 }] }
                    { events := [{ unitId := 1, status := "on", timestamp := 100 },
                                 { unitId := 2, status := "off", timestamp := 200 }] } := by
  unfold Spec; decide
