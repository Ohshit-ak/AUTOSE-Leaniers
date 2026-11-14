import ContractForge
open ContractForge

-- 2.1.1.2.1.10/S1: The system shall perform a search in the Active Directory to verify the status of the user - Active/Inactive within the company-when the user attempts to create/add a new user in the [system name] system.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  username : String
  deriving DecidableEq, Repr

structure Output where
  status  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ ""
  post := fun i o => o.status = "Active" ↔
    (i.username = "admin" → o.status = "Active") ∧
    (i.username ≠ "admin" → o.status = "Inactive")

example : Spec.pre { username := "john" } ∧ Spec.post { username := "john" } { status := "" } := by
  unfold Spec; decide
