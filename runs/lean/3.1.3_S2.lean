-- 3.1.3/S2: Customers will be able to register, log in, and log out of their accounts.
-- checked: None

structure Contract (Input Output : Type) where
  pre  : Input → Prop
  post : Input → Output → Prop

structure AccountState where
  username : String
  password : String
  logged_in : Bool

def Spec : Contract AccountState AccountState where
  pre i := true
  post i o := 
    (o.logged_in = i.logged_in) ∧
    (i.logged_in = false → o.username = "" ∧ o.password = "") ∧
    (i.logged_in = true → o.username ≠ "" ∧ o.password ≠ "")

example : Spec := 
{ pre := fun _ => true,
  post := fun i o =>
    (o.logged_in = i.logged_in) ∧
    (i.logged_in = false → o.username = "" ∧ o.password = "") ∧
    (i.logged_in = true → o.username ≠ "" ∧ o.password ≠ "") }
