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
  quantity : Nat
  deriving DecidableEq, Repr

structure Output where
  cart : Cart
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.action ∈ ["add", "remove"] ∧
                   (i.product = none → 0 < i.quantity) ∧
                   (i.product = some p → p ∈ i.cart.items)
  post := fun i o => (i.action = "add" →
    o.cart.items.length = i.cart.items.length + 1 ∧
    o.cart.items.contains i.product.get! ∧
    o.cart.items.count i.product.get! = i.quantity) ∧
                     (i.action = "remove" →
    o.cart.items.length = i.cart.items.length - 1 ∧
    o.cart.items.count i.product.get! = 0)

example : Spec.pre { cart := { items := [{ name := "apple", price := 100 }] },
                     action := "add", product := some { name := "apple", price := 100 },
                     quantity := 2 } ∧
          Spec.post { cart := { items := [{ name := "apple", price := 100 }] },
                      action := "add", product := some { name := "apple", price := 100 },
                      quantity := 2 }
                    { cart := { items := [{ name := "apple", price := 100 }, { name := "apple", price := 100 }] } } := by
  unfold Spec; decide
