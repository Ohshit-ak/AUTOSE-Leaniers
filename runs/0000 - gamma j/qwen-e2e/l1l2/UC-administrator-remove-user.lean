import ContractForge
open ContractForge

-- UC-administrator-remove-user: Remove User: Remove a user from the system.

-- L0 spec

structure Account where
  username : String
  deriving DecidableEq, Repr

structure Input where
  accounts : List Account
  username : String
  deriving DecidableEq, Repr

structure Output where
  accounts : List Account
  deleted  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ ""
  post := fun i o => o.deleted = true ∧
                     (∃ a ∈ i.accounts, a.username = i.username) ∧
                     (o.accounts = i.accounts.filter (fun a => a.username ≠ i.username))

example : Spec.pre { accounts := [{ username := "alice" }, { username := "bob" }],
                     username := "bob" } ∧
          Spec.post { accounts := [{ username := "alice" }, { username := "bob" }],
                      username := "bob" }
                    { accounts := [{ username := "alice" }], deleted := true } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Account where
  username : String
  deriving DecidableEq, Repr

structure Input where
  accounts : List Account
  username : String
  deriving DecidableEq, Repr

structure Output where
  accounts : List Account
  deleted  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ ""
  post := fun i o => o.deleted = true ∧
                     (∃ a ∈ i.accounts, a.username = i.username) ∧
                     (o.accounts = i.accounts.filter (fun a => a.username ≠ i.username))

-- Component 1: Filter Accounts
def FilterAccountsContract : Contract (Input × Account) (Account × Bool) where
  pre  := fun (i, a) => i.username = a.username
  post := fun (i, a) (o, b) => b = (a.username = i.username) ∧
                               (o = if a.username = i.username then a else { username := a.username })

-- Component 2: Apply Filter to List
def ApplyFilterContract : Contract (List (Input × Account)) (List (Account × Bool)) where
  pre  := fun l => ∀ (i, a) ∈ l, i.username = a.username
  post := fun l o => o = l.filter (fun (i, a) => a.username = i.username)

-- Prove PO1: FilterAccountsContract is compatible with ApplyFilterContract
example : Contract.Compatible FilterAccountsContract ApplyFilterContract := by
  intros l o
  simp [ApplyFilterContract.post, FilterAccountsContract.post]
  constructor
  -- First part of the conjunction
  simp [FilterAccountsContract.pre, ApplyFilterContract.pre]
  -- Second part of the conjunction
  simp [FilterAccountsContract.post, ApplyFilterContract.post]

-- Prove PO2: Composition of contracts refines the spec
def FilterAndApplyContract : Contract Input Output := by
  discharge_po (FilterAccountsContract.seq ApplyFilterContract).Refines Spec

example : FilterAndApplyContract.pre { accounts := [{ username := "alice" }, { username := "bob" }],
                                       username := "bob" } ∧
          FilterAndApplyContract.post { accounts := [{ username := "alice" }, { username := "bob" }],
                                        username := "bob" }
                    { accounts := [{ username := "alice" }], deleted := true } := by
  unfold FilterAndApplyContract; decide