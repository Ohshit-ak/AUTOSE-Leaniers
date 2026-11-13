import ContractForge
open ContractForge

-- 3.3.4.1/I3: Exchange of control information, in the form of commands and status information. (Bi-directional traffic) (see also Section 3.1.1 on page 3- 1). •Collection and transfer (for archiving or remote access) of raw astronomical

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { commandAck := x.command, statusAck := x.status }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
