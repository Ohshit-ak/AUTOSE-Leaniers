-- UC-administrator-remove-user: Remove User: Remove a user from the system.
-- checked: None

structure User := (name : String)

structure SystemState := (users : List User)

structure Input := (userId : User)

def Spec : Contract Input SystemState where
  pre input sys := 
    input.userId ∈ sys.users ::ᵥ sys.users
  post input sys sys' := 
    sys'.users = List.filter (· ≠ input.userId) sys.users ∧
    List.Pairwise (· ≤ ·) sys'.users

example : Spec (Input.mk {name := "Alice"}) (SystemState.mk []) (SystemState.mk []) :=
begin
  unfold Spec,
  simp,
  split,
  { simp, },
  { simp, },
end
