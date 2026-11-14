import ContractForge
open ContractForge

-- 3.1.1.2/S1: The TCS in the Recovery Startup Mode shall provide the system functionality to resume the Operations State within 45 seconds. [SSS029] 10 Recovery of the TCS HWCIs shall include startup of HWCIs [SSS543], download of software [SSS544], startup of CSCIs [SSS545], and establishment of the state of readiness of all interfaces. [SSS546] The TCS shall be capable of automatically recording system state data, interface communications and other information necessary to support event reconstruction. [SSS528] **DELETED**. [SSS030] For recovery from abnormal termination, TCS shall prompt the operator to select the type of recovery to be executed: (1)Resume in the Same Modes And Data; (2)Resume in the Same Modes but Review and Modify the Command Data as Necessary; or, (3) Perform a Command Shutdown and Startup Via the Normal Startup Mode. [SSS031]
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

-- IMPL: Python benchmark measures the time taken to resume the Operations State in the Recovery Startup Mode

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≤ 45000000 ∧
                     (o.elapsedMicros = 0 → False) ∧
                     (o.elapsedMicros > 0 ↔ True)

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 44999999 } := by
  unfold Spec; decide
