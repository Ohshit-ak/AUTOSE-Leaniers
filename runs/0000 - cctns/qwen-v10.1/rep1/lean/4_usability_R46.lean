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
  profileName : String
  deriving DecidableEq, Repr

structure Output where
  profiles : List Profile
  modified : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.profiles.Nodup ∧ i.profileName ≠ ""
  post := fun i o =>
    (o.modified = true ↔
      ∃ p ∈ i.profiles, p.name = i.profileName) ∧
    (∀ p ∈ o.profiles, p ∈ i.profiles) ∧
    (∀ p ∈ i.profiles, p ∈ o.profiles →
      (p.name = i.profileName →
        p.email = o.profiles.filter (fun p' => p'.name = i.profileName).hd.email ∧
        p.phone = o.profiles.filter (fun p' => p'.name = i.profileName).hd.phone) ∧
      (p.name ≠ i.profileName →
        p.email = p.email ∧ p.phone = p.phone))

example : Spec.pre { profiles := [{ name := "Alice", email := "alice@example.com", phone := "1234567890" }],
                     profileName := "Alice" } ∧
          Spec.post { profiles := [{ name := "Alice", email := "alice@example.com", phone := "1234567890" }],
                      profileName := "Alice" }
                    { profiles := [{ name := "Alice", email := "alice@example.com", phone := "1234567890" }],
                      modified := true } := by
  unfold Spec; decide
