import ContractForge
open ContractForge

-- UC-administrator-add-user: Add User: Register a new customer, sales person, or administrator account with the system

-- L0 spec

structure Account where
  username : String
  password : String
  role     : String
  privileges : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  role     : String
  privileges : String
  deriving DecidableEq, Repr

structure Output where
  username : String
  password : String
  role     : String
  privileges : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧
                 (i.role = "customer" ∨ i.role = "sales person" ∨ i.role = "administrator") ∧
                 (i.privileges = "read" ∨ i.role = "customer")
  post := fun i o => o.username = i.username ∧ o.password = i.password ∧
                     (o.role = i.role ∧ o.privileges = "read" ∨
                      o.role = "customer" ∧ o.privileges = i.privileges)

example : Spec.pre { username := "newuser", password := "pass123", role := "customer", privileges := "read" } ∧
          Spec.post { username := "newuser", password := "pass123", role := "customer", privileges := "read" }
                    { username := "newuser", password := "pass123", role := "customer", privileges := "read" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  role     : String
  privileges : String
  username : String
  password : String
  deriving DecidableEq, Repr

def ComputeRoleAndPrivilegesContract : Contract Input Mid where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧
                 (i.role = "customer" ∨ i.role = "sales person" ∨ i.role = "administrator") ∧
                 (i.privileges = "read" ∨ i.role = "customer")
  post := fun i m => (m.role = i.role ∧ m.privileges = "read" ∨
                     (m.role = "customer" ∧ m.privileges = i.privileges)) ∧ m.username = i.username ∧ m.password = i.password

def ApplyRoleAndPrivilegesContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.username = m.username ∧ o.password = m.password ∧
                     (o.role = m.role ∧ o.privileges = "read" ∨
                      o.role = "customer" ∧ o.privileges = m.privileges)

theorem po1 : Contract.Compatible ComputeRoleAndPrivilegesContract ApplyRoleAndPrivilegesContract := by
  discharge_po1 [ComputeRoleAndPrivilegesContract, ApplyRoleAndPrivilegesContract, Spec]

theorem po2 : Contract.Refines (ComputeRoleAndPrivilegesContract.seq ApplyRoleAndPrivilegesContract) Spec := by
  discharge_po2 [ComputeRoleAndPrivilegesContract, ApplyRoleAndPrivilegesContract, Spec]

-- L2 ComputeRoleAndPrivilegesContract (success=True)

def ComputeRoleAndPrivilegesContractImpl (x : Input) : Mid :=
  { role := x.role,
    privileges := if x.role = "customer" then x.privileges else "read",
    username := x.username,
    password := x.password }

theorem ComputeRoleAndPrivilegesContractImpl_ok : ComputeRoleAndPrivilegesContract.Satisfies ComputeRoleAndPrivilegesContractImpl := by
  discharge_po3 [ComputeRoleAndPrivilegesContract, ComputeRoleAndPrivilegesContractImpl]

-- L2 ApplyRoleAndPrivilegesContract (success=True)

def ApplyRoleAndPrivilegesContractImpl (x : Mid) : Output :=
  { username := x.username,
    password := x.password,
    role := x.role,
    privileges := if x.role = "customer" then x.privileges else "read" }

theorem ApplyRoleAndPrivilegesContractImpl_ok : ApplyRoleAndPrivilegesContract.Satisfies ApplyRoleAndPrivilegesContractImpl := by
  discharge_po3 [ApplyRoleAndPrivilegesContract, ApplyRoleAndPrivilegesContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (ApplyRoleAndPrivilegesContractImpl ∘ ComputeRoleAndPrivilegesContractImpl) :=
  Contract.system_sound po1 po2 ComputeRoleAndPrivilegesContractImpl_ok ApplyRoleAndPrivilegesContractImpl_ok
