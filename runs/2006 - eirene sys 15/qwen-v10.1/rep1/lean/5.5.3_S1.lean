import ContractForge
open ContractForge

-- 5.5.3/S1: The Cab radio system shall provide a means for the driver to terminate established calls which he is authorised to terminate.
-- compiles: True · rejects_bad_example: True · checked: True

structure Call where
  id : Nat
  driverId : Nat
  status : String
  deriving DecidableEq, Repr

structure Input where
  calls : List Call
  driverId : Nat
  deriving DecidableEq, Repr

structure Output where
  calls : List Call
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.driverId ≠ 0
  post := fun i o => (o.calls = i.calls ∧
    ∀ c ∈ i.calls, c.driverId = i.driverId →
    (c.status = "terminated" ↔
      ∃ c' ∈ i.calls, c' = c ∧ (c'.status = "terminated" ∨ c'.status = "terminated" && c.driverId = i.driverId)))

example : Spec.pre { calls := [], driverId := 1 } ∧ Spec.post { calls := [], driverId := 1 } { calls := [] } := by
  unfold Spec; decide
