import ContractForge
open ContractForge

-- 3.4.3/S2: If the order is incorrect, the customer will be able to revise and update their order.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  incorrectOrder : Bool
  revisedOrder   : Option String
  deriving DecidableEq, Repr

structure Output where
  updatedOrder   : Bool
  order         : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.incorrectOrder = true
  post := fun i o => o.updatedOrder = true ∧
                     (o.order = i.revisedOrder.getD "") = i.incorrectOrder

example : Spec.pre { incorrectOrder := true, revisedOrder := some "Corrected Item" } ∧
          Spec.post { incorrectOrder := true, revisedOrder := some "Corrected Item" }
                    { updatedOrder := true, order := "Corrected Item" } := by
  unfold Spec; decide
