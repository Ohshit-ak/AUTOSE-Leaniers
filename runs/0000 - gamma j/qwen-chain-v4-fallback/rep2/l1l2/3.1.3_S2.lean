import ContractForge
open ContractForge

-- 3.1.3/S2: Customers will be able to register, log in, and log out of their accounts.

-- L0 spec

structure Account where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  action   : String
  accounts : List Account
  deriving DecidableEq, Repr

structure Output where
  username : String
  logged   : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => (o.logged = true ↔
    i.action = "login" ∧
    ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password) ∧
    (o.logged = false ↔
    (i.action = "logout" ∧ o.username = i.username) ∨
    (i.action = "register" ∧ i.username ∉ i.accounts.map (·.username)))

example : Spec.pre { username := "john", password := "pass123", action := "login", accounts := [{ username := "john", password := "pass123" }] } ∧ Spec.post { username := "john", password := "pass123", action := "login", accounts := [{ username := "john", password := "pass123" }] } { username := "john", logged := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { username := x.username, logged := decide (x.action = "login" ∧
    ∃ a ∈ x.accounts, a.username = x.username ∧ a.password = x.password) }
