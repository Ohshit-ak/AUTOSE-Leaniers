import ContractForge
open ContractForge

-- 3.3.4.1/I3: Exchange of control information, in the form of commands and status information. (Bi-directional traffic) (see also Section 3.1.1 on page 3- 1). •Collection and transfer (for archiving or remote access) of raw astronomical
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  command : String
  status  : String
  deriving DecidableEq, Repr

structure Output where
  commandAck : String
  statusAck  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.command ≠ "" ∧ i.status ≠ ""
  post := fun i o => (o.commandAck = i.command) ∧
                     (o.statusAck = i.status)

example : Spec.pre { command := "start", status := "ready" } ∧
          Spec.post { command := "start", status := "ready" }
                    { commandAck := "start", statusAck := "ready" } := by
  unfold Spec; decide
