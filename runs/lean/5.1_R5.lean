-- 5.1/R5: The system shall be able to search for a specified product in less than 1 second.
-- checked: None

structure Product where
  name : String
  price : Nat

structure SearchRequest where
  name : String

structure Output where
  foundProduct : Option Product
  elapsedMicros : Nat

def Spec : Contract SearchRequest Output where
  pre req := true
  post req res := 
    match res.foundProduct with
    | some p => true
    | none => false
    <|| res.elapsedMicros < 1000000

example : Spec (SearchRequest.mk "Laptop") (Output.mk (some (Product.mk "Laptop" 1000)) 500000) := by
  decide

example : Spec (SearchRequest.mk "Laptop") (Output.mk none 1500000) := by
  decide
