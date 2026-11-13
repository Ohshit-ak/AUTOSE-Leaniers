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
                  (i.role = "customer" ∨ i.role = "sales person" ∨ i.role = "administrator")
  post := fun i o => o.username = i.username ∧ o.password = i.password ∧
                     o.role = i.role ∧ o.privileges = i.privileges

example : Spec.pre { username := "newuser", password := "pass123", role := "customer", privileges := "read" } ∧
          Spec.post { username := "newuser", password := "pass123", role := "customer", privileges := "read" }
                    { username := "newuser", password := "pass123", role := "customer", privileges := "read" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { username := x.username, password := x.password, role := x.role, privileges := x.privileges }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
