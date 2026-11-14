import ContractForge
open ContractForge

-- 3.1/S1: The states of operation of the TCS shall include Startup, Operation, and Shutdown. [SSS014] The TCS states shall not exist concurrently. [SSS015] Figure 3.1-1 shows the existing states of the TCS.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { state := x.state }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
