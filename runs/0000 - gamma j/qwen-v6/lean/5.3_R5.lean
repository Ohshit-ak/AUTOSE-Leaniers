import ContractForge
open ContractForge

-- 5.3/R5: The system shall detect consecutive failed login attempts.
-- compiles: False · rejects_bad_example: None · checked: False

structure Account where
  username : String
  password : String
  failedAttempts : Nat := 0
  lastAttempt : Nat := 0
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
    ∃ a ∈ i.accounts, a.username = i.username ∧ a.password ≠ i.password ∧
    a.failedAttempts < 3 ∧ (a.failedAttempts + 1) = a.failedAttempts) ∧
    (o.signedIn = false ↔
    ∃ a ∈ i.accounts, a.username = i.username ∧ a.password ≠ i.password ∧
    a.failedAttempts = 3 ∧ (a.failedAttempts + 1) = a.failedAttempts)

example : Spec.pre { accounts := [{ username := "sam", password := "wrong", failedAttempts := 2, lastAttempt := 0 }],
                     username := "sam", password := "wrong" } ∧
          Spec.post { accounts := [{ username := "sam", password := "wrong", failedAttempts := 3, lastAttempt := 1 }],
                      username := "sam", password := "wrong" }
                    { signedIn := false } := by
  unfold Spec; decide

structure Account where
  username : String
  password : String
  failedAttempts : Nat := 0
  lastAttempt : Nat := 0
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
    ∃ a ∈ i.accounts, a.username = i.username ∧ a.password ≠ i.password ∧
    a.failedAttempts < 3 ∧ (a.failedAttempts + 1) = a.failedAttempts) ∧
    (o.signedIn = false ↔
    ∃ a ∈ i.accounts, a.username = i.username ∧ a.password ≠ i.password ∧
    a.failedAttempts = 3 ∧ (a.failedAttempts + 1) = a.failedAttempts)

example : Spec.pre { accounts := [{ username := "sam", password := "wrong", failedAttempts := 2, lastAttempt := 0 }],
                     username := "sam", password := "wrong" } ∧
          Spec.post { accounts := [{ username := "sam", password := "wrong", failedAttempts := 3, lastAttempt := 1 }],
                      username := "sam", password := "wrong" }
                    { signedIn := false } := by
  unfold Spec; decide
