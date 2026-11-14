import ContractForge
open ContractForge

-- 2.1.1.2.1.8/S1: The system shall save the user info to the database with specified roles associated with divisions for the newly created/added user.

-- L0 spec

structure Role where
  name : String
  deriving DecidableEq, Repr

structure Division where
  id   : Nat
  name : String
  deriving DecidableEq, Repr

structure User where
  username : String
  roles    : List Role
  divisions : List Division
  deriving DecidableEq, Repr

structure Input where
  username : String
  roles    : List Role
  divisions : List Division
  deriving DecidableEq, Repr

structure Output where
  username : String
  roles    : List Role
  divisions : List Division
  saved    : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.roles.Nodup ∧ i.divisions.Nodup
  post := fun i o => o.username = i.username ∧ o.roles = i.roles ∧
                     o.divisions = i.divisions ∧
                     o.saved = true

example : Spec.pre { username := "newuser", roles := [ { name := "admin" }, { name := "editor" } ],
                     divisions := [ { id := 1, name := "HR" }, { id := 2, name := "IT" } ] } ∧
          Spec.post { username := "newuser", roles := [ { name := "admin" }, { name := "editor" } ],
                      divisions := [ { id := 1, name := "HR" }, { id := 2, name := "IT" } ] }
                    { username := "newuser", roles := [ { name := "admin" }, { name := "editor" } ],
                      divisions := [ { id := 1, name := "HR" }, { id := 2, name := "IT" } ], saved := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { username := x.username,
    roles := x.roles,
    divisions := x.divisions,
    saved := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
