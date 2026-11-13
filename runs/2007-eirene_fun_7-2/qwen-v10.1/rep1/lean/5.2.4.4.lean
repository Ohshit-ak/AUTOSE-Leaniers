import ContractForge
open ContractForge

-- 5.2.4.4: 5.2.4.4 The Cab radio may be required to set up calls from a number of different sources. Therefore, the radio shall provide a priority function for calls from different sources in order to handle contention for the radio. (M)
-- compiles: True · rejects_bad_example: False · checked: False

structure Input where
  calls : List String
  deriving DecidableEq, Repr

structure Output where
  selectedCall : String
  priority     : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.calls.length > 0
  post := fun i o => 
    (∃ c ∈ i.calls, o.selectedCall = c ∧ o.priority = i.calls.idxOf? c) ∧
    (o.priority = i.calls.idxOf? o.selectedCall)

example : Spec.pre { calls := ["call1", "call2", "call3"] } ∧
          Spec.post { calls := ["call1", "call2", "call3"] }
                    { selectedCall := "call1", priority := 0 } := by
  unfold Spec; decide
