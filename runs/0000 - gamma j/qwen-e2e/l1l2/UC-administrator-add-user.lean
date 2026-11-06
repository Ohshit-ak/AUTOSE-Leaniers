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
  isCustomer : Bool
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
                 i.isCustomer
  post := fun i o => (o.username = i.username ∧ o.password = i.password ∧
                      o.role = i.role ∧ o.privileges = i.privileges) ↔
                    (i.isCustomer ∧
                     o.username ≠ "" ∧ o.password ≠ "" ∧
                     o.role = "customer" ∧ o.privileges ≠ "")

example : Spec.pre { username := "newuser", password := "password123", role := "customer", privileges := "read", isCustomer := true } ∧
          Spec.post { username := "newuser", password := "password123", role := "customer", privileges := "read", isCustomer := true }
                    { username := "newuser", password := "password123", role := "customer", privileges := "read" } := by
  unfold Spec; decide

-- L1 architect (success=False)

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
  isCustomer : Bool
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
                   i.isCustomer
  post := fun i o => (o.username = i.username ∧ o.password = i.password ∧
                      o.role = i.role ∧ o.privileges = i.privileges) ↔
                    (i.isCustomer ∧
                     o.username ≠ "" ∧ o.password ≠ "" ∧
                     o.role = "customer" ∧ o.privileges ≠ "")

def ValidateInputContract : Contract Input Input where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧
                   (i.role = "customer" ∨ i.role = "sales person" ∨ i.role = "administrator") ∧
                   i.isCustomer
  post := fun i i' => i = i'

def TransformOutputContract : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧
                   (i.role = "customer" ∨ i.role = "sales person" ∨ i.role = "administrator") ∧
                   i.isCustomer
  post := fun i o => (o.username = i.username ∧ o.password = i.password ∧
                      o.role = i.role ∧ o.privileges = i.privileges) ↔
                    (i.isCustomer ∧
                     o.username ≠ "" ∧ o.password ≠ "" ∧
                     o.role = "customer" ∧ o.privileges ≠ "")

-- Prove PO1: ValidateInputContract is compatible with itself
theorem PO1_ValidateInputContract : Contract.Compatible (ValidateInputContract) (ValidateInputContract) := by
  discharge_po

-- Prove PO1: TransformOutputContract is compatible with ValidateInputContract
theorem PO1_TransformOutputContract : Contract.Compatible (ValidateInputContract) (TransformOutputContract) := by
  discharge_po

-- Prove PO2: The composition of ValidateInputContract and TransformOutputContract refines the spec
theorem PO2_TransformOutputContract : Contract.Refines (ValidateInputContract.seq TransformOutputContract) Spec := by
  discharge_po