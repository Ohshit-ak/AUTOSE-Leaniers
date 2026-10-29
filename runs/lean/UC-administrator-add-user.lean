-- UC-administrator-add-user: Add User: Register a new customer, sales person, or administrator account with the system
-- checked: None

structure User where
  name : String
  email : String
  role : String

structure SystemState where
  users : List User

structure Input where
  newUser : User

structure Output where
  newAccountCreated : Bool

def Spec : Contract Input Output where
  pre input := true
  post input output := 
    output.newAccountCreated ∧
    input.newUser :: SystemState.users = SystemState.users

example : Spec Input Output :=
  { pre := fun _ => true,
    post := fun input output => 
      output.newAccountCreated ∧
      input.newUser :: SystemState.users = SystemState.users }
