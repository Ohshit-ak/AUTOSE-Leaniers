import ContractForge
open ContractForge

-- 3.1.3/S2: Customers will be able to register, log in, and log out of their accounts.
-- compiles: False · rejects_bad_example: None · checked: False

structure Account where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Input where
  accounts : List Account
  username : String
  password : String
  action   : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.action ∈ ["register", "login", "logout"]
  post := fun i o => 
    match i.action with
    | "register" => o.signedIn = false
    | "login" => 
      if ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password then
        o.signedIn = true
      else
        o.signedIn = false
    | "logout" => o.signedIn = i.signedIn

example : Spec.pre { accounts := [{ username := "sam", password := "pw1" }],
                     username := "sam", password := "pw1", action := "login" } ∧
          Spec.post { accounts := [{ username := "sam", password := "pw1" }],
                      username := "sam", password := "pw1", action := "login" }
                    { signedIn := true } := by
  unfold Spec; decide

example : Spec.pre { accounts := [{ username := "sam", password := "pw1" }],
                     username := "sam", password := "pw1", action := "logout" } ∧
          Spec.post { accounts := [{ username := "sam", password := "pw1" }],
                      username := "sam", password := "pw1", action := "logout" }
                    { signedIn := false } := by
  unfold Spec; decide

example : Spec.pre { accounts := [{ username := "sam", password := "pw1" }],
                     username := "sam", password := "pw1", action := "register" } ∧
          Spec.post { accounts := [{ username := "sam", password := "pw1" }],
                      username := "sam", password := "pw1", action := "register" }
                    { signedIn := false } := by
  unfold Spec; decide
