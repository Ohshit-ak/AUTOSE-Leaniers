import ContractForge
open ContractForge

-- 5.3/R5: The system shall detect consecutive failed login attempts.

-- L0 spec

structure Account where
  username : String
  password : String
  failedAttempts : Nat
  deriving DecidableEq, Repr

structure Input where
  accounts : List Account
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  accounts : List Account
  accepted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ ""
  post := fun i o =>
    (o.accepted = true ↔
      ∃ a ∈ i.accounts, a.username = i.username ∧
      (a.failedAttempts < 3 ∧ a.password = i.password)) ∧
    (o.accepted = false →
      ∃ a ∈ i.accounts, a.username = i.username ∧
      (a.failedAttempts = 3 ∨ a.failedAttempts > 3 ∧ a.password ≠ i.password)) ∧
    ∀ a ∈ o.accounts, a.failedAttempts = a.failedAttempts + (if o.accepted then 0 else 1)

example : Spec.pre { accounts := [{ username := "user1", password := "pw1", failedAttempts := 2 }], username := "user1", password := "pw1" } ∧ Spec.post { accounts := [{ username := "user1", password := "pw1", failedAttempts := 2 }], username := "user1", password := "pw1" } { accounts := [{ username := "user1", password := "pw1", failedAttempts := 2 }], accepted := true } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  accepted : Bool
  accounts : List Account
  username : String
  password : String
  deriving DecidableEq, Repr

def AuthenticateContract : Contract Input Mid where
  pre  := fun i => i.username ≠ ""
  post := fun i m => (m.accepted = true ↔
                     ∃ a ∈ i.accounts, a.username = i.username ∧
                     (a.failedAttempts < 3 ∧ a.password = i.password)) ∧
                    (m.accepted = false →
                     ∃ a ∈ i.accounts, a.username = i.username ∧
                     (a.failedAttempts = 3 ∨ a.failedAttempts > 3 ∧ a.password ≠ i.password))

def UpdateAccountsContract : Contract Mid Output where
  pre  := fun m => True
  post := fun m o => m.accepted = o.accepted ∧
                     (o.accepted = false →
                       ∃ a ∈ m.accounts, a.username = m.username ∧
                       (a.failedAttempts = 3 ∨ a.failedAttempts > 3 ∧ a.password ≠ m.password)) ∧
                     ∀ a ∈ o.accounts, a.failedAttempts = a.failedAttempts + (if o.accepted then 0 else 1)

theorem po1 : Contract.Compatible AuthenticateContract UpdateAccountsContract := by
  discharge_po1 [AuthenticateContract, UpdateAccountsContract, Spec]

theorem po2 : Contract.Refines (AuthenticateContract.seq UpdateAccountsContract) Spec := by
  discharge_po2 [AuthenticateContract, UpdateAccountsContract, Spec]

-- L2 AuthenticateContract (success=False)

def AuthenticateContractImpl (x : Input) : Mid :=
  { accepted := decide (∃ a ∈ x.accounts, a.username = x.username ∧
                     (a.failedAttempts < 3 ∧ a.password = x.password)),
    accounts := x.accounts,
    username := x.username,
    password := x.password }

-- L2 UpdateAccountsContract (success=False)

def UpdateAccountsContractImpl (x : Mid) : Output :=
  { accounts := x.accounts.map (fun a =>
    { username := a.username,
      password := a.password,
      failedAttempts := if x.accepted then a.failedAttempts + 1 else a.failedAttempts + (if a.failedAttempts = 3 ∨ a.failedAttempts > 3 ∧ a.password ≠ x.password then 1 else 0) }),
    accepted := x.accepted }
