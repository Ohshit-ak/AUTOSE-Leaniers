import ContractForge
open ContractForge

-- 4.3.1/S2: EPICS consists of a set of hardware and software components from which a control system can be created.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  components : List String
  deriving DecidableEq, Repr

structure Output where
  controlSystem : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.components.Nodup
  post := fun i o => o.controlSystem.Nodup ∧
                     o.controlSystem.length ≤ i.components.length ∧
                     (∀ c ∈ o.controlSystem, c ∈ i.components) ∧
                     (o.controlSystem = i.components)

example : Spec.pre { components := ["HMI", "PLC", "DAQ"] } ∧
          Spec.post { components := ["HMI", "PLC", "DAQ"] }
                    { controlSystem := ["HMI", "PLC", "DAQ"] } := by
  unfold Spec; decide
