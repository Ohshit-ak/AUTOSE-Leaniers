import ContractForge
open ContractForge

-- 4/usability/R46: Allowing users to see and change profiles: If user-specified profiles are used, users should be able to see, modify and delete that profile on demand.
-- compiles: False · rejects_bad_example: None · checked: False

structure Profile where
  name   : String
  email  : String
  phone  : String
  deriving DecidableEq, Repr

structure Input where
  profiles : List Profile
  selected : Option Profile
  deriving DecidableEq, Repr

structure Output where
  profiles : List Profile
  selected : Option Profile
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.selected.isSome
  post := fun i o => (o.profiles = i.profiles ∧
                      o.selected.getD i.selected = i.selected.getD i.selected) ∧
                     (o.selected.isSome ↔ i.selected.isSome) ∧
                     (o.selected.isNone → o.profiles = i.profiles)

example : Spec.pre { profiles := [{ name := "Alice", email := "a@example.com", phone := "1234567890" }],
                     selected := some { name := "Alice", email := "a@example.com", phone := "1234567890" } } ∧
          Spec.post { profiles := [{ name := "Alice", email := "a@example.com", phone := "1234567890" }],
                      selected := some { name := "Alice", email := "a@example.com", phone := "1234567890" } }
                    { profiles := [{ name := "Alice", email := "a@example.com", phone := "1234567890" }],
                      selected := some { name := "Alice", email := "a@example.com", phone := "1234567890" } } := by
  unfold Spec; decide
