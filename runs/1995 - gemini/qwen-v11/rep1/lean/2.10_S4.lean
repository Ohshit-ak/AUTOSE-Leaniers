import ContractForge
open ContractForge

-- 2.10/S4: Critical resources (those that can support only a restricted number of simultaneous uses) are assigned solely through this allocation system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  criticalResource : Nat
  allocatedUsers   : List Nat
  maxUsers         : Nat
  deriving DecidableEq, Repr

structure Output where
  allocatedUsers   : List Nat
  maxUsers         : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.maxUsers > 0
  post := fun i o => o.maxUsers = i.maxUsers ∧
                     (o.allocatedUsers.length ≤ i.maxUsers) ∧
                     (∀ u ∈ o.allocatedUsers, u ∈ i.allocatedUsers) ∧
                     (o.allocatedUsers.length < i.allocatedUsers.length →
                      o.allocatedUsers.length = i.maxUsers) ∧
                     (o.allocatedUsers.length = i.allocatedUsers.length →
                      o.allocatedUsers = i.allocatedUsers)

example : Spec.pre { criticalResource := 1, allocatedUsers := [1, 2], maxUsers := 3 } ∧
          Spec.post { criticalResource := 1, allocatedUsers := [1, 2], maxUsers := 3 }
                    { allocatedUsers := [1, 2], maxUsers := 3 } := by
  unfold Spec; decide
