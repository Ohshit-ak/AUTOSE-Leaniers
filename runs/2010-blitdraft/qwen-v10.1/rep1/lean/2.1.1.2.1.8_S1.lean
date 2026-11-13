import ContractForge
open ContractForge

-- 2.1.1.2.1.8/S1: The system shall save the user info to the database with specified roles associated with divisions for the newly created/added user.
-- compiles: True · rejects_bad_example: True · checked: True

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
                     divisions := [ { id := 1, name := "Sales" }, { id := 2, name := "Marketing" } ] } ∧
          Spec.post { username := "newuser", roles := [ { name := "admin" }, { name := "editor" } ],
                      divisions := [ { id := 1, name := "Sales" }, { id := 2, name := "Marketing" } ] }
                    { username := "newuser", roles := [ { name := "admin" }, { name := "editor" } ],
                      divisions := [ { id := 1, name := "Sales" }, { id := 2, name := "Marketing" } ], saved := true } := by
  unfold Spec; decide
