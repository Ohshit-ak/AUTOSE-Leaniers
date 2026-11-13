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
  deriving DecidableEq, Repr

structure Output where
  received : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.received = true ↔
    ∃ c ∈ i.calls, c.dispatcher.isSome ∨ c.group.isSome ∧
    (c.dispatcher.isSome → ∃ d ∈ i.calls.dispatcher, d.id = c.dispatcher.get) ∨
    (c.group.isSome → ∃ g ∈ i.calls.group, g.id = c.group.get ∧ c.group.get ∈ g.members)

example : Spec.pre { calls := [{ id := 1, dispatcher := some 2, group := none },
                                { id := 2, dispatcher := none, group := some 3 },
                                { id := 3, dispatcher := some 4, group := some 5 }] } ∧
          Spec.post { calls := [{ id := 1, dispatcher := some 2, group := none },
                                 { id := 2, dispatcher := none, group := some 3 },
                                 { id := 3, dispatcher := some 4, group := some 5 }] }
                    { received := true } := by
  unfold Spec; decide
