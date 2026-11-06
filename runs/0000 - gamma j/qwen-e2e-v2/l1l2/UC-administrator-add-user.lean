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

structure Mid where
  username : String
  password : String
  role     : String
  privileges : String
  isCustomer : Bool
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧
                 (i.role = "customer" ∨ i.role = "sales person" ∨ i.role = "administrator") ∧
                 i.isCustomer
  post := fun i m => (m.username = i.username ∧ m.password = i.password ∧
                      m.role = i.role ∧ m.privileges = i.privileges) ↔
                    (i.isCustomer ∧
                     m.username ≠ "" ∧ m.password ≠ "" ∧
                     m.role = "customer" ∧ m.privileges ≠ "")

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.username ≠ "" ∧ m.password ≠ "" ∧
                 m.role = "customer" ∧ m.privileges ≠ ""
  post := fun m o => (o.username = m.username ∧ o.password = m.password ∧
                      o.role = m.role ∧ o.privileges = m.privileges) ↔
                    (m.isCustomer ∧
                     o.username ≠ "" ∧ o.password ≠ "" ∧
                     o.role = "customer" ∧ o.privileges ≠ "")

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  unfold Contract.Compatible ValidateContract ComputeContract
  intro i m _ h
  simp only at h
  rw [h.2.2]
  exact h.1

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateContract ComputeContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨hp, hq, _⟩, ho⟩
  simp only at *
  rw [ho, hp, hq]
  exact hq.2