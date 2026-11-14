import ContractForge
open ContractForge

-- 2.4.5: 2.4.5 The network shall provide a mechanism whereby calls may be assigned one of a number of different priority levels. (M)
-- compiles: True · rejects_bad_example: None · checked: True

structure Call where
  priority : Nat
  deriving DecidableEq, Repr

structure Input where
  calls : List Call
  deriving DecidableEq, Repr

structure Output where
  calls : List Call
  deriving DecidableEq, Repr

def ValidPriority (c : Call) : Bool :=
  0 ≤ c.priority ∧ c.priority ≤ 10

def Spec : Contract Input Output where
  pre  := fun i => i.calls.Nodup ∧ i.calls.all ValidPriority
  post := fun i o => o.calls = i.calls.filter ValidPriority

example : Spec.pre { calls := [{ priority := 5 }, { priority := 7 }] } ∧
          Spec.post { calls := [{ priority := 5 }, { priority := 7 }] }
                    { calls := [{ priority := 5 }, { priority := 7 }] } := by
  unfold Spec; decide
