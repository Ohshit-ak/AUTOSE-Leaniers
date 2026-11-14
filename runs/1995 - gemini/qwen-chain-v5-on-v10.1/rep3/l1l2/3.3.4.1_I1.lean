import ContractForge
open ContractForge

-- 3.3.4.1/I1: Local coordination and synchronization needs within a subsystem (for example, coordination of active support system for primary mirror, bi-directional traffic of commands/replies). This layer could be considered as internal to a given subsystem or instrument, but as more than one subsystem might need it, one should aim for a unique solution at the hardware and software level.

-- L0 spec

structure Input where
  command : String
  deriving DecidableEq, Repr

structure Output where
  reply   : String
  status  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.command = "sync" ∨ i.command = "coord"
  post := fun i o => o.status = true ↔ (i.command = "sync" ∧ o.reply = "OK") ∨
                     (i.command = "coord" ∧ o.reply = "ACK") ∨
                     (i.command = "sync" ∧ o.reply = "ERROR" ∧ o.status = false) ∨
                     (i.command = "coord" ∧ o.reply = "ERROR" ∧ o.status = false)

example : Spec.pre { command := "sync" } ∧ Spec.post { command := "sync" } { reply := "OK", status := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { reply := if x.command = "sync" then "OK" else "ACK",
    status := if x.command = "sync" then true else false }
