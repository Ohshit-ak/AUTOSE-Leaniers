import ContractForge
open ContractForge

-- CI-1: The WebOrder system shall send an e-mail confirmation to the customer that the items they ordered will be delivered to the shipping address along with tracking number.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  email    : String
  items    : List String
  address  : String
  tracking : String
  deriving DecidableEq, Repr

structure Output where
  sent     : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email ≠ "" ∧ i.address ≠ "" ∧ i.tracking ≠ ""
  post := fun i o => o.sent = true ↔
    (i.email ≠ "" ∧ i.address ≠ "" ∧ i.tracking ≠ "")

example : Spec.pre { email := "customer@example.com", items := ["item1", "item2"], address := "123 Main St", tracking := "1234567890" } ∧
          Spec.post { email := "customer@example.com", items := ["item1", "item2"], address := "123 Main St", tracking := "1234567890" }
                    { sent := true } := by
  unfold Spec; decide
