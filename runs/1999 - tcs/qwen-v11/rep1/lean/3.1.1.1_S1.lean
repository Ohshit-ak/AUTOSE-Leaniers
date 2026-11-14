import ContractForge
open ContractForge

-- 3.1.1.1/S1: When executing in the Normal Startup Mode, the TCS shall provide the system functionality necessary to initialize the system to place it in the Operations State within 60 seconds from the time power is supplied and the TCS application is launched. [SSS024] Initialization of the TCS HWCIs shall include startup of HWCIs [SSS542], download of software [SSS026], startup of CSCIs [SSS027], execution of Startup FD/L [SSS025], and establishment of the state of readiness of all interfaces. [SSS028]
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≤ 60000000

example : Spec.pre { } ∧ Spec.post { elapsedMicros := 59999999 } := by
  unfold Spec; decide
