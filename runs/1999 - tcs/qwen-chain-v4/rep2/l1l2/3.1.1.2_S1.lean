import ContractForge
open ContractForge

-- 3.1.1.2/S1: The TCS in the Recovery Startup Mode shall provide the system functionality to resume the Operations State within 45 seconds. [SSS029] 10 Recovery of the TCS HWCIs shall include startup of HWCIs [SSS543], download of software [SSS544], startup of CSCIs [SSS545], and establishment of the state of readiness of all interfaces. [SSS546] The TCS shall be capable of automatically recording system state data, interface communications and other information necessary to support event reconstruction. [SSS528] **DELETED**. [SSS030] For recovery from abnormal termination, TCS shall prompt the operator to select the type of recovery to be executed: (1)Resume in the Same Modes And Data; (2)Resume in the Same Modes but Review and Modify the Command Data as Necessary; or, (3) Perform a Command Shutdown and Startup Via the Normal Startup Mode. [SSS031]

-- L0 spec

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  operation     : Bool
  deriving DecidableEq, Repr

-- IMPL: The TCS in the Recovery Startup Mode shall provide the system functionality to resume the Operations State within 45 seconds.

def Spec : Contract Input Output where
  pre  := fun _ => true
  post := fun _ o => o.operation ↔ o.elapsedMicros ≤ 45000000

example : Spec.pre { } ∧ Spec.post { } { operation := true, elapsedMicros := 44999999 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { elapsedMicros := 45000000, operation := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
