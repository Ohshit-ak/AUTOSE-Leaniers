import ContractForge
open ContractForge

-- 2.1.1.2.1.1/S1: A user with admin privileges shall be able to Add/Create a new user and associate the user with specified role(s) in the system.

-- L0 spec

structure Role where
  name : String
  deriving DecidableEq, Repr

structure User where
  username : String
  password : String
  roles    : List Role
  deriving DecidableEq, Repr

structure Input where
  username  : String
  password  : String
  roles     : List Role
  admin     : Bool
  deriving DecidableEq, Repr

structure Output where
  success   : Bool
  new_user  : User
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.admin = true
  post := fun i o => o.success ↔
    (i.username ≠ "" ∧ i.password ≠ "" ∧ i.roles.Nodup ∧
     ∃ r ∈ i.roles, r.name = "admin") ∧
    o.new_user = { username := i.username, password := i.password, roles := i.roles }

example : Spec.pre { username := "admin", password := "pass", roles := [], admin := true } ∧ Spec.post { username := "admin", password := "pass", roles := [], admin := true } { success := false, new_user := { username := "admin", password := "pass", roles := [] } } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { success := x.admin ∧ x.username ≠ "" ∧ x.password ≠ "" ∧ x.roles.Nodup ∧
               ∃ r, r ∈ x.roles ∧ r.name = "admin", 
    new_user := { username := x.username, password := x.password, roles := x.roles } }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
