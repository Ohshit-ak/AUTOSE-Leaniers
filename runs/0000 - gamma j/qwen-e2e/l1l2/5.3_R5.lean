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
      (a.failedAttempts = 3 ∨ a.failedAttempts + 1 = 3))

example : Spec.pre { accounts := [{ username := "user1", password := "pw1", failedAttempts := 2 }],
                     username := "user1", password := "pw1" } ∧
          Spec.post { accounts := [{ username := "user1", password := "pw1", failedAttempts := 2 }],
                      username := "user1", password := "pw1" }
                    { accepted := true, accounts := [{ username := "user1", password := "pw1", failedAttempts := 2 }] } := by
  unfold Spec; decide

example : Spec.pre { accounts := [{ username := "user1", password := "pw1", failedAttempts := 2 }],
                     username := "user1", password := "pw2" } ∧
          Spec.post { accounts := [{ username := "user1", password := "pw1", failedAttempts := 2 }],
                      username := "user1", password := "pw2" }
                    { accepted := false, accounts := [{ username := "user1", password := "pw1", failedAttempts := 3 }] } := by
  unfold Spec; decide

-- L1 architect (success=False)

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
      (a.failedAttempts = 3 ∨ a.failedAttempts + 1 = 3))

-- Decompose the spec into two components

def CheckPasswordContract : Contract (Input × Account) Bool where
  pre  := fun (i, a) => i.username = a.username ∧ a.password = i.password
  post := fun (i, a) o => o ↔ a.failedAttempts < 3

def UpdateAccountContract : Contract (Input × Account) Output where
  pre  := fun (i, a) => i.username = a.username ∧ a.failedAttempts < 3
  post := fun (i, a) o =>
    o.accepted = true ∧
    o.accounts = i.accounts.map (fun a' => if a' = a then { a with failedAttempts := a.failedAttempts + 1 } else a') ∧
    (o.accepted = false →
      ∃ a' ∈ i.accounts, a' = a ∧ a'.failedAttempts = 3 ∨ a'.failedAttempts + 1 = 3)

-- Prove PO1 and PO2

@[simp] lemma CheckPasswordContract_compatible : Contract.Compatible (CheckPasswordContract.seq UpdateAccountContract) Spec :=
begin
  unfold CheckPasswordContract UpdateAccountContract Spec,
  simp,
  intros i o,
  split,
  { simp only [CheckPasswordContract.pre, UpdateAccountContract.pre, Spec.pre],
    simp,
    exact dec_trivial },
  { simp only [CheckPasswordContract.post, UpdateAccountContract.post, Spec.post],
    simp,
    exact dec_trivial }
end

@[simp] lemma UpdateAccountContract_refines : Contract.Refines (CheckPasswordContract.seq UpdateAccountContract) Spec :=
begin
  unfold CheckPasswordContract UpdateAccountContract Spec,
  simp,
  intros i o,
  split,
  { simp only [CheckPasswordContract.pre, UpdateAccountContract.pre, Spec.pre],
    simp,
    exact dec_trivial },
  { simp only [CheckPasswordContract.post, UpdateAccountContract.post, Spec.post],
    simp,
    exact dec_trivial }
end

-- Example checks

example : Spec.pre { accounts := [{ username := "user1", password := "pw1", failedAttempts := 2 }],
                     username := "user1", password := "pw1" } ∧
          Spec.post { accounts := [{ username := "user1", password := "pw1", failedAttempts := 2 }],
                      username := "user1", password := "pw1" }
                    { accepted := true, accounts := [{ username := "user1", password := "pw1", failedAttempts := 2 }] } := by
  unfold Spec; decide

example : Spec.pre { accounts := [{ username := "user1", password := "pw1", failedAttempts := 2 }],
                     username := "user1", password := "pw2" } ∧
          Spec.post { accounts := [{ username := "user1", password := "pw1", failedAttempts := 2 }],
                      username := "user1", password := "pw2" }
                    { accepted := false, accounts := [{ username := "user1", password := "pw1", failedAttempts := 3 }] } := by
  unfold Spec; decide