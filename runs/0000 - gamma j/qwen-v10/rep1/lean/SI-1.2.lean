import ContractForge
open ContractForge

-- SI-1.2: Through programmatic interface, WebOrder will transmit information of items ordered by customers to the Inventory management system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Item where
  name   : String
  amount : Nat
  deriving DecidableEq, Repr

structure Input where
  items : List Item
  deriving DecidableEq, Repr

structure Output where
  success : Bool
  message : String
  deriving DecidableEq, Repr

-- Define a dummy function for the InventoryManagementSystem
def InventoryManagementSystem.receiveOrder (items : List Item) : Bool :=
  items.all (fun item => item.amount ≤ 100)

def Spec : Contract Input Output where
  pre  := fun i => i.items.Nodup
  post := fun i o => o.success ↔
    (∃ items' ∈ i.items, items'.amount ≤ 100) ∧
    (o.message = "Order successfully transmitted." ↔
      (∀ item ∈ i.items, item.amount ≤ 100) ∧
      InventoryManagementSystem.receiveOrder i.items)

example : Spec.pre { items := [{ name := "book", amount := 50 },
                               { name := "pen", amount := 80 }] } ∧
          Spec.post { items := [{ name := "book", amount := 50 },
                                { name := "pen", amount := 80 }] }
                    { success := true, message := "Order successfully transmitted." } := by
  unfold Spec; decide
