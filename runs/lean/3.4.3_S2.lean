-- 3.4.3/S2: If the order is incorrect, the customer will be able to revise and update their order.
-- checked: None

structure Order where
  items : List String
  quantities : List Nat

structure RevisedOrder where
  items : List String
  quantities : List Nat

structure Customer where
  order : Order
  revisedOrder : Option RevisedOrder

def Spec : Contract Customer (Bool × Option RevisedOrder) where
  pre c := c.order.items ≠ [] ∧ c.order.quantities = c.order.items.length
  post c res := 
    match res with
    | (false, none) := c.order.items = [] ∨ c.order.quantities ≠ c.order.items.length
    | (true, some ro) := 
      c.order.items = ro.items ∧
      c.order.quantities = ro.quantities ∧
      c.revisedOrder = some ro
    | _ := false

example : Spec (Customer.{u} ⟨[], []⟩ none) (false, none) := by
  simp

example : Spec (Customer.{u} ⟨["item1"], [1]⟩ none) (true, some ⟨["item1"], [1]⟩) := by
  simp
