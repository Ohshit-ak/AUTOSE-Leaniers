import ContractForge
open ContractForge

-- 2.3.4: 2.3.4 If the text message facility is implemented, it shall not interfere with the ability of users to make or receive high priority voice or data calls. (M) General data applications

-- L0 spec

structure Input where
  user : String
  priority : Bool
  message : String
  deriving DecidableEq, Repr

structure Output where
  callSuccessful : Bool
  messageSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.priority = true
  post := fun i o => (o.callSuccessful = true ↔ i.priority = true) ∧
                     (o.messageSent = false ↔ i.message ≠ "" ∧ i.priority = true)

example : Spec.pre { user := "alice", priority := true, message := "" } ∧ Spec.post { user := "alice", priority := true, message := "" } { callSuccessful := true, messageSent := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { callSuccessful := x.priority, messageSent := x.message = "" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
