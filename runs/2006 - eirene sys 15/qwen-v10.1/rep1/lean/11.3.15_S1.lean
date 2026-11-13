import ContractForge
open ContractForge

-- 11.3.15/S1: Deregistration of a functional number shall not be carried out until registration of the functional number has been carried out and confirmed as being successful.
-- compiles: True · rejects_bad_example: None · checked: True

structure FunctionalNumber where
  id : Nat
  status : String
  deriving DecidableEq, Repr

structure Input where
  deregistered : Nat
  registered   : Nat
  status       : String
  deriving DecidableEq, Repr

structure Output where
  deregistered : Nat
  registered    : Nat
  status        : String
  success       : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.status = "registered" ∧ i.registered ≠ 0
  post := fun i o => (o.success = true ↔ i.deregistered = i.registered) ∧
                     (o.success = false → o.deregistered = i.deregistered ∧ o.registered = i.registered)

example : Spec.pre { deregistered := 0, registered := 1, status := "registered" } ∧ Spec.post { deregistered := 0, registered := 1, status := "registered" } { deregistered := 0, registered := 1, status := "deregistered", success := false } := by
  unfold Spec; decide
