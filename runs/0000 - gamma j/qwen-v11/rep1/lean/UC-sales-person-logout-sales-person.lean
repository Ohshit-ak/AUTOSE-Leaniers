import ContractForge
open ContractForge

-- UC-sales-person-logout-sales-person: Logout Sales Person: Logout the Sales Person account on the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Session where
  username : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  logged_in : Bool
  deriving DecidableEq, Repr

structure Output where
  username : String
  logged_in : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.logged_in = true
  post := fun i o => o.username = i.username ∧ o.logged_in = false

example : Spec.pre { username := "salesperson", logged_in := true } ∧
          Spec.post { username := "salesperson", logged_in := true }
                    { username := "salesperson", logged_in := false } := by
  unfold Spec; decide
