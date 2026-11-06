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

-- L1 architect (success=True)

structure Mid where
  accounts : List Account
  username : String
  deleted  : Bool
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.username ≠ ""
  post := fun i m => m.deleted = true ∧
                     (∃ a ∈ i.accounts, a.username = i.username) ∧
                     (m.accounts = i.accounts.filter (fun a => a.username ≠ i.username))

def UpdateContract : Contract Mid Output where
  pre  := fun m => m.deleted
  post := fun m o => o.accounts = m.accounts ∧
                     o.deleted = m.deleted

theorem po1 : Contract.Compatible ValidateContract UpdateContract := by
  discharge_po [Spec, UpdateContract, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq UpdateContract) Spec := by
  discharge_po [Spec, UpdateContract, ValidateContract]

-- L2 ValidateContract (success=False)

def ValidateContractImpl (i : Input) : Mid :=
  { accounts := i.accounts.filter (fun a => a.username ≠ i.username),
    username := i.username,
    deleted := true }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  unfold Contract.Satisfies; simp_all

-- L2 UpdateContract (success=True)

def UpdateContractImpl (m : Mid) : Output := { accounts := m.accounts, deleted := m.deleted }

theorem UpdateContractImpl_ok : UpdateContract.Satisfies UpdateContractImpl := by
  discharge_po [Spec, UpdateContract, UpdateContractImpl, ValidateContract]