import ContractForge
open ContractForge

-- 3.1/S1: The states of operation of the TCS shall include Startup, Operation, and Shutdown. [SSS014] The TCS states shall not exist concurrently. [SSS015] Figure 3.1-1 shows the existing states of the TCS.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  state : String
  deriving DecidableEq, Repr

structure Output where
  state : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.state ∈ ["Startup", "Operation", "Shutdown"]
  post := fun i o => o.state = i.state ∧
                     (o.state = "Startup" ↔ i.state = "Startup") ∧
                     (o.state = "Operation" ↔ i.state = "Operation") ∧
                     (o.state = "Shutdown" ↔ i.state = "Shutdown")

example : Spec.pre { state := "Startup" } ∧
          Spec.post { state := "Startup" } { state := "Startup" } := by
  unfold Spec; decide
