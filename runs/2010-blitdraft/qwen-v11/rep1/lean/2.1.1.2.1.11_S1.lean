import ContractForge
open ContractForge

-- 2.1.1.2.1.11/S1: The system shall generate a standard confirmation message after saving data and warning/caution messages after the cancel or close button is clicked.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  username : String
  password : String
  confirm  : Bool
  cancel   : Bool
  deriving DecidableEq, Repr

structure Output where
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => (o.message = "User data saved successfully." ↔ i.confirm) ∧
                     (o.message = "Operation cancelled." ↔ i.cancel)

example : Spec.pre { username := "test", password := "pass", confirm := true, cancel := false } ∧
          Spec.post { username := "test", password := "pass", confirm := true, cancel := false }
                    { message := "User data saved successfully." } := by
  unfold Spec; decide
