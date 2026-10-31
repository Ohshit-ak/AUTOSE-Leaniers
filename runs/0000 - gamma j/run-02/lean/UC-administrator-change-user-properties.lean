-- UC-administrator-change-user-properties: Change User Properties: Alter properties such as passwords and privileges of the user.
-- checked: True

structure Input where
  username : String
  newProps : String
  deriving DecidableEq, Repr

structure Output where
  altered : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.altered = true

example : Spec.pre { username := "admin", newProps := "new_password" } ∧
          Spec.post { username := "admin", newProps := "new_password" } { altered := true } := by
  unfold Spec; decide
