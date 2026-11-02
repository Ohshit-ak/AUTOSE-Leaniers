import ContractForge
open ContractForge

-- 5.1/R9: The system shall be able to restore 1000 records per second.
-- compiles: True · rejects_bad_example: None · checked: False

structure Account where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Input where
  accounts : List Account
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => (o.signedIn = true ↔
    ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password)

example : Spec.pre { accounts := [{ username := "sam", password := "pw1" }],
                     username := "sam", password := "pw1" } ∧
          Spec.post { accounts := [{ username := "sam", password := "pw1" }],
                      username := "sam", password := "pw1" }
                    { signedIn := true } := by
  unfold Spec; decide
