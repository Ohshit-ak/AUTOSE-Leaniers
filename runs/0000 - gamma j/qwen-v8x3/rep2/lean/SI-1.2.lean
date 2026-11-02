import ContractForge
open ContractForge

-- SI-1.2: Through programmatic interface, WebOrder will transmit information of items ordered by customers to the Inventory management system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  itemsOrdered : List String
  deriving DecidableEq, Repr

structure Output where
  itemsReceived : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.itemsOrdered.Nodup
  post := fun i o => o.itemsReceived = i.itemsOrdered

example : Spec.pre { itemsOrdered := ["apple", "banana"] } ∧
          Spec.post { itemsOrdered := ["apple", "banana"] }
                    { itemsReceived := ["apple", "banana"] } := by
  unfold Spec; decide
