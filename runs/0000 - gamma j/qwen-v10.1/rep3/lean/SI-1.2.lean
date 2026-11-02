import ContractForge
open ContractForge

-- SI-1.2: Through programmatic interface, WebOrder will transmit information of items ordered by customers to the Inventory management system.
-- compiles: True · rejects_bad_example: None · checked: True

structure Item where
  code : String
  quantity : Nat
  deriving DecidableEq, Repr

structure Input where
  items : List Item
  deriving DecidableEq, Repr

structure Output where
  items : List Item
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.items.Nodup
  post := fun i o => o.message = "Items received successfully" ↔
                      (∀ it ∈ i.items, it.quantity > 0) ∧
                      List.Perm i.items o.items

example : Spec.pre { items := [{ code := "A1", quantity := 5 }, { code := "B2", quantity := 3 }] } ∧
          Spec.post { items := [{ code := "A1", quantity := 5 }, { code := "B2", quantity := 3 }] }
                     { items := [{ code := "A1", quantity := 5 }, { code := "B2", quantity := 3 }], message := "Items received successfully" } := by
  unfold Spec; decide
