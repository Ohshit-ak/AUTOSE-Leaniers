import ContractForge
open ContractForge

-- 2.10/S4: Critical resources (those that can support only a restricted number of simultaneous uses) are assigned solely through this allocation system.

-- L0 spec

structure Input where
  criticalResource : Nat
  concurrentUsers  : Nat
  isCritical       : Bool
  deriving DecidableEq, Repr

structure Output where
  assigned        : Bool
  concurrentUsers : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.concurrentUsers
  post := fun i o => (o.assigned = true ↔ i.isCritical) ∧
                     (o.assigned = false → o.concurrentUsers = i.concurrentUsers) ∧
                     o.concurrentUsers = i.concurrentUsers

example : Spec.pre { criticalResource := 1, concurrentUsers := 5, isCritical := true } ∧
          Spec.post { criticalResource := 1, concurrentUsers := 5, isCritical := true }
                    { assigned := true, concurrentUsers := 5 } := by
  unfold Spec; decide

example : Spec.pre { criticalResource := 1, concurrentUsers := 5, isCritical := false } ∧
          Spec.post { criticalResource := 1, concurrentUsers := 5, isCritical := false }
                    { assigned := false, concurrentUsers := 5 } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  assigned : Bool
  concurrentUsers : Nat
  deriving DecidableEq, Repr

def ComputeAssignedContract : Contract Input Mid where
  pre  := fun i => 0 < i.concurrentUsers
  post := fun i m => m.assigned = i.isCritical ∧ m.concurrentUsers = i.concurrentUsers

def AssignUsersContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.assigned = true ↔ m.assigned) ∧
                     (o.assigned = false → o.concurrentUsers = m.concurrentUsers)
