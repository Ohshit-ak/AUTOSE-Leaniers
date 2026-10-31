-- 3.1.3/S2: Customers will be able to register, log in, and log out of their accounts.
-- checked: False

structure Input where
  action : String
  username : String
  password : String

structure Output where
  success : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.action ∈ ["register", "login", "logout"]
  post := fun i o => 
    match i.action with
    | "register" => o.success = true ↔ i.username ≠ "" ∧ i.password ≠ ""
    | "login" => o.success = true ↔ i.username ≠ "" ∧ i.password ≠ ""
    | "logout" => o.success = true

example : Spec.pre ⟨"register", "user1", "pass1"⟩ ∧ Spec.post ⟨"register", "user1", "pass1"⟩ ⟨true⟩ := by
  simp [Spec]
