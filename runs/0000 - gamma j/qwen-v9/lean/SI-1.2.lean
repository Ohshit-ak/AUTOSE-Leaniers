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
  accepted : Bool
  message  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.items.Nodup
  post := fun i o => (o.accepted = true ↔ i.items.all (fun x => 0 < x.amount)) ∧
                     (o.accepted = false → o.message = "One or more items have zero or negative amount.")

example : Spec.pre { items := [{ name := "book", amount := 5 }, { name := "pen", amount := 3 }] } ∧
          Spec.post { items := [{ name := "book", amount := 5 }, { name := "pen", amount := 3 }] }
                    { accepted := true, message := "" } := by
  unfold Spec; decide
