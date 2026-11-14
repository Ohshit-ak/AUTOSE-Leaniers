import ContractForge
open ContractForge

-- 3.4.1/S8: This should greatly simplify the coordination problem posed by the large number of simultaneous users (as already described in the Capacity requirements, Section 3.2.2).

-- L0 spec

structure Input where
  maxUsers : Nat
  currentUsers : Nat
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  currentUsers : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.maxUsers
  post := fun i o => (o.accepted = true ↔ i.currentUsers < i.maxUsers) ∧
                     (o.accepted = false → o.currentUsers = i.currentUsers + 1)

example : Spec.pre { maxUsers := 10, currentUsers := 8 } ∧
          Spec.post { maxUsers := 10, currentUsers := 8 }
                    { accepted := true, currentUsers := 9 } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  accepted : Bool
  currentUsers : Nat
  deriving DecidableEq, Repr

def CheckUserCountContract : Contract Input Mid where
  pre  := fun i => 0 < i.maxUsers
  post := fun i m => (m.accepted = true ↔ i.currentUsers < i.maxUsers) ∧ m.currentUsers = i.currentUsers

def UpdateUserCountContract : Contract Mid Output where
  pre  := fun m => m.accepted = false
  post := fun m o => o.accepted = false → o.currentUsers = m.currentUsers + 1
