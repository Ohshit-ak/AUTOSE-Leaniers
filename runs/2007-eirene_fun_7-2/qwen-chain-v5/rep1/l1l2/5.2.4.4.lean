import ContractForge
open ContractForge

-- 5.2.4.4: 5.2.4.4 The Cab radio may be required to set up calls from a number of different sources. Therefore, the radio shall provide a priority function for calls from different sources in order to handle contention for the radio. (M)

-- L0 spec

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
    (∃ c ∈ i.calls, o.selectedCall = c ∧ o.priority = i.calls.idxOf c) ∧
    (o.priority = i.calls.idxOf o.selectedCall)

example : Spec.pre { calls := ["call1", "call2", "call3"] } ∧
          Spec.post { calls := ["call1", "call2", "call3"] }
                    { selectedCall := "call3", priority := 2 } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { selectedCall := x.calls.last,
    priority := x.calls.indexOf x.selectedCall }
