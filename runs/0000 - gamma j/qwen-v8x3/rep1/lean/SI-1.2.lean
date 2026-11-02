import ContractForge
open ContractForge

-- SI-1.2: Through programmatic interface, WebOrder will transmit information of items ordered by customers to the Inventory management system.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  itemsOrdered : List String
  deriving DecidableEq, Repr

structure Output where
  success : Bool
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.itemsOrdered.Nodup
  post := fun i o => o.success ↔ i.itemsOrdered.length > 0 ∧
                      o.message = "Order transmitted successfully" ∧
                      o.success = true

example : Spec.pre { itemsOrdered := ["item1", "item2"] } ∧
          Spec.post { itemsOrdered := ["item1", "item2"] }
                    { success := true, message := "Order transmitted successfully" } := by
  unfold Spec; decide
