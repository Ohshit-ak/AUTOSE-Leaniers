import ContractForge
open ContractForge

-- 5.5.3/S1: The Cab radio system shall provide a means for the driver to terminate established calls which he is authorised to terminate.
-- compiles: True · rejects_bad_example: None · checked: False

structure Call where
  id : Nat
  driver : String
  status : String
  deriving DecidableEq, Repr

structure Input where
  calls : List Call
  driver : String
  deriving DecidableEq, Repr

structure Output where
  calls : List Call
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.driver ≠ ""
  post := fun i o => 
    (∀ c ∈ o.calls, c ∈ i.calls ∧ (c.status = "terminated" ↔ c.driver = i.driver)) ∧
    o.calls.length = i.calls.length

example : Spec.pre { driver := "John Doe", calls := [{ id := 1, driver := "John Doe", status := "active" }] } ∧
          Spec.post { driver := "John Doe", calls := [{ id := 1, driver := "John Doe", status := "terminated" }] }
                    { calls := [{ id := 1, driver := "John Doe", status := "terminated" }] } := by
  unfold Spec; decide
