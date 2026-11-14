import ContractForge
open ContractForge

-- 11.3.15/S1: Deregistration of a functional number shall not be carried out until registration of the functional number has been carried out and confirmed as being successful.
-- compiles: True · rejects_bad_example: True · checked: True

structure FunctionalNumber where
  number : Nat
  registered : Bool
  deriving DecidableEq, Repr

structure Input where
  number : Nat
  registered : Bool
  deriving DecidableEq, Repr

structure Output where
  deregistered : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.registered
  post := fun i o => o.deregistered = false ∧
                     (o.deregistered = true ↔ i.registered = false)

example : Spec.pre { number := 123, registered := true } ∧
          Spec.post { number := 123, registered := true }
                    { deregistered := false } := by
  unfold Spec; decide
