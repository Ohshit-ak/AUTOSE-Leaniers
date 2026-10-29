-- 5.1/R3: The system shall be able to retrieve 200 products per second.
-- checked: None

structure Product where
  id : Nat
  name : String

structure Input where
  products : List Product

structure Output where
  retrieved : Nat := 0
  perSecond : Nat

def Spec : Contract Input Output where
  pre input := true
  post input output := output.retrieved ≥ 200 ∧ output.perSecond = 200

example : Spec (Input { products := List.nil }) (Output { retrieved := 200, perSecond := 200 }) := by
  decide
