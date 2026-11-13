import ContractForge
open ContractForge

-- 5.5.24/S1: Calls shall be able to be terminated by either party subject to the requirements shown in tables 5A-2 and 5A-3.

-- L0 spec

structure Call where
  callerId : Nat
  status   : String
  deriving DecidableEq, Repr

structure Input where
  callerId : Nat
  status   : String
  otherParty : Nat
  deriving DecidableEq, Repr

structure Output where
  callerId : Nat
  status   : String
  otherParty : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.status = "active"
  post := fun i o => (o.status = "terminated" ↔
    (i.callerId = i.otherParty ∨
     (i.callerId = o.callerId ∧ o.status = "terminated" ∧
      i.status = "terminated" → o.callerId = i.callerId))) ∧
    (o.status = "terminated" →
     (i.callerId = o.callerId ∧ o.callerId = o.otherParty) ∨
     (i.callerId = o.otherParty ∧ o.callerId = i.callerId))

example : Spec.pre { callerId := 1, status := "active", otherParty := 2 } ∧
          Spec.post { callerId := 1, status := "active", otherParty := 2 }
                    { callerId := 1, status := "terminated", otherParty := 1 } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { callerId := x.callerId,
    status := "terminated",
    otherParty := if x.callerId = x.otherParty then x.callerId else x.otherParty }
