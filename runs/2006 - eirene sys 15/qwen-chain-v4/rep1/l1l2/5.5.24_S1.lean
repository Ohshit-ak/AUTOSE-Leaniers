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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  callerId : Nat
  status   : String
  deriving DecidableEq, Repr

def ComputeStatusContract : Contract Input Mid where
  pre  := fun i => i.status = "active"
  post := fun i m => m.callerId = i.callerId ∧ m.status = "terminated" ↔
    (i.callerId = i.otherParty ∨
     (i.callerId = m.callerId ∧ m.status = "terminated" ∧
      i.status = "terminated" → m.callerId = i.callerId))

def ApplyStatusContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => m.callerId = o.callerId ∧ m.status = "terminated" ↔
    (o.status = "terminated" →
     (m.callerId = o.callerId ∧ o.callerId = o.otherParty) ∨
     (m.callerId = o.otherParty ∧ o.callerId = m.callerId))
