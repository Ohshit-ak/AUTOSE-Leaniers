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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { accounts := x.accounts.filter (fun a => a.username ≠ x.username), deleted := true }
