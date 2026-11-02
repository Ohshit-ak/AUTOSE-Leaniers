import ContractForge
open ContractForge

-- 3.4.3/S2: If the order is incorrect, the customer will be able to revise and update their order.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  orderItems : List String
  customerName : String
  deriving DecidableEq, Repr

structure Output where
  orderItems : List String
  customerName : String
  revised : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.orderItems.length > 0
  post := fun i o => o.revised = true ↔
    ∃ item ∈ i.orderItems, item ≠ "corrected" ∧
    o.orderItems = i.orderItems.map (fun item => if item = "corrected" then "corrected" else item) ∧
    o.customerName = i.customerName

example : Spec.pre { orderItems := ["item1", "item2"], customerName := "John Doe" } ∧
          Spec.post { orderItems := ["item1", "item2"], customerName := "John Doe" }
                    { revised := true, orderItems := ["item1", "item2"], customerName := "John Doe" } := by
  unfold Spec; decide
