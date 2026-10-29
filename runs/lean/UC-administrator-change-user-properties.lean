-- UC-administrator-change-user-properties: Change User Properties: Alter properties such as passwords and privileges of the user.
-- checked: None

structure UserProperties where
  password : String
  privileges : List String

structure SystemState where
  users : List (String × UserProperties)

structure Input where
  username : String
  newProperties : UserProperties

def Spec : Contract Input SystemState where
  pre s i := 
    ∃ u : String × UserProperties, 
      u.1 = i.username ∧ 
      List.mem u s.users
  post s i s' := 
    ∃ u : String × UserProperties, 
      u.1 = i.username ∧ 
      u.2 = i.newProperties ∧ 
      s'.users = s.users.update u

example : Spec (Input.mk "user1" { password := "newpass", privileges := ["admin"] }) (SystemState.mk [{ "user1", UserProperties.mk "oldpass" ["user"] }]) (SystemState.mk [{ "user1", UserProperties.mk "newpass" ["admin"] }]) :=
  begin
    simp [update, List.update, List.mem, List.Perm],
    exact ⟨⟨"user1", UserProperties.mk "newpass" ["admin"]⟩, by simp⟩
  end
