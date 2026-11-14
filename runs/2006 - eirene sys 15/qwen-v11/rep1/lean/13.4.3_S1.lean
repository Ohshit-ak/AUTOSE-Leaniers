import ContractForge
open ContractForge

-- 13.4.3/S1: The fixed network user will only receive emergency voice calls if designated a dispatcher or group member in any of the calls defined in the GSM GCR.
-- compiles: False · rejects_bad_example: None · checked: False

structure Dispatcher where
  id : Nat
  name : String
  deriving DecidableEq, Repr

structure Group where
  id : Nat
  name : String
  members : List Nat
  deriving DecidableEq, Repr

structure Call where
  id : Nat
  dispatcher : Option Nat
  group : Option Nat
  deriving DecidableEq, Repr

structure Input where
  calls : List Call
  user : Nat
  deriving DecidableEq, Repr

structure Output where
  received : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.received = true ↔
    ∃ c ∈ i.calls, (c.dispatcher = i.user ∨ c.group.getD i.user ∈ i.calls.map Call.dispatcher)

example : Spec.pre { calls := [{ id := 1, dispatcher := some 2, group := none },
                                { id := 2, dispatcher := none, group := some 3 }],
                     user := 2 } ∧
          Spec.post { calls := [{ id := 1, dispatcher := some 2, group := none },
                                { id := 2, dispatcher := none, group := some 3 }],
                      user := 2 }
                    { received := true } := by
  unfold Spec; decide
