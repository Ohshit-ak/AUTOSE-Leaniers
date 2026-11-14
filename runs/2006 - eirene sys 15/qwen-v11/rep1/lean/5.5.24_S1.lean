import ContractForge
open ContractForge

-- 5.5.24/S1: Calls shall be able to be terminated by either party subject to the requirements shown in tables 5A-2 and 5A-3.
-- compiles: False · rejects_bad_example: None · checked: False

structure Call where
  caller   : String
  callee   : String
  status   : String
  deriving DecidableEq, Repr

structure Input where
  calls    : List Call
  caller   : String
  terminating : Bool
  deriving DecidableEq, Repr

structure Output where
  calls    : List Call
  deriving DecidableEq, Repr

-- A call can be terminated if the terminating party is the caller and the call is in progress
def CanTerminate (i : Input) : Bool :=
  i.terminating && i.caller = i.calls.map (fun c => c.caller).headOption.getD ""

def Spec : Contract Input Output where
  pre  := fun i => i.caller ≠ "" ∧ i.calls.Nodup
  post := fun i o => (o.calls = i.calls ∧
    (i.terminating →
      ∃ c ∈ i.calls, c.caller = i.caller ∧ c.status = "in progress" ∧ c.status = o.calls.map (fun c' => c'.status).headOption.getD "")) ∧
    (¬i.terminating → o.calls = i.calls)

example : Spec.pre { calls := [{ caller := "Alice", callee := "Bob", status := "in progress" }],
                     caller := "Alice", terminating := true } ∧
          Spec.post { calls := [{ caller := "Alice", callee := "Bob", status := "terminated" }],
                      caller := "Alice", terminating := true } := by
  unfold Spec; decide
