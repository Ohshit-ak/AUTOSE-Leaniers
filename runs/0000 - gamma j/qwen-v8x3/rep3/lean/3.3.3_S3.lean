import ContractForge
open ContractForge

-- 3.3.3/S3: The customer will also be able to add to or remove products from the shopping cart prior to checkout and order confirmation.
-- compiles: False · rejects_bad_example: None · checked: False

structure Product where
  name : String
  price : Nat
  deriving DecidableEq, Repr

structure Cart where
  items : List Product
  deriving DecidableEq, Repr

structure Input where
  cart : Cart
  action : String
  product : Option Product
  quantity : Option Nat
  deriving DecidableEq, Repr

structure Output where
  cart : Cart
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cart.items.Nodup
  post := fun i o => o.cart.items = 
    if i.action = "add" then
      match i.product, i.quantity with
      | some p, some q => i.cart.items.push { p with quantity := p.quantity + q }
      | _, _ => i.cart.items
    else if i.action = "remove" then
      match i.product, i.quantity with
      | some p, some q => i.cart.items.filter (fun x => x.name ≠ p.name ∨ x.quantity - q ≤ 0)
      | _, _ => i.cart.items
    else
      i.cart.items

example : Spec.pre { cart := { items := [{ name := "A1", price := 10, quantity := 5 }] },
                     action := "add", product := some { name := "A1", price := 10, quantity := 5 },
                     quantity := some 3 } ∧
          Spec.post { cart := { items := [{ name := "A1", price := 10, quantity := 8 }] },
                      action := "add", product := some { name := "A1", price := 10, quantity := 5 },
                      quantity := some 3 }
                    { cart := { items := [{ name := "A1", price := 10, quantity := 8 }] } } := by
  unfold Spec; decide

example : Spec.pre { cart := { items := [{ name := "A1", price := 10, quantity := 5 }] },
                     action := "remove", product := some { name := "A1", price := 10, quantity := 5 },
                     quantity := some 3 } ∧
          Spec.post { cart := { items := [{ name := "A1", price := 10, quantity := 2 }] },
                      action := "remove", product := some { name := "A1", price := 10, quantity := 5 },
                      quantity := some 3 }
                    { cart := { items := [{ name := "A1", price := 10, quantity := 2 }] } } := by
  unfold Spec; decide
