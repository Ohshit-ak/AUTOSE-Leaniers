import ContractForge
open ContractForge

-- 0/S6: First of all, D2.1 will be updated and improved in the following respects:
-- compiles: True · rejects_bad_example: None · checked: True

structure UserProfile where
  name    : String
  email   : String
  age     : Nat
  deriving DecidableEq, Repr

structure Input where
  profile : UserProfile
  newName : String
  newEmail: String
  newAge  : Nat
  deriving DecidableEq, Repr

structure Output where
  updatedProfile : UserProfile
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.newName ≠ "" ∧ i.newEmail ≠ "" ∧ 0 < i.newAge
  post := fun i o => o.updatedProfile = { name := i.newName,
                                           email := i.newEmail,
                                           age := i.newAge }

example : Spec.pre { profile := { name := "Alice", email := "alice@example.com", age := 30 },
                     newName := "Alicia", newEmail := "alicia@example.com", newAge := 31 } ∧
          Spec.post { profile := { name := "Alice", email := "alice@example.com", age := 30 },
                      newName := "Alicia", newEmail := "alicia@example.com", newAge := 31 }
                    { updatedProfile := { name := "Alicia", email := "alicia@example.com", age := 31 } } := by
  unfold Spec; decide
