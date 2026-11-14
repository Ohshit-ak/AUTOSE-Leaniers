import ContractForge
open ContractForge

-- 11.3.2.3: 11.3.2.3 It shall be possible to register up to ten functional numbers to items of equipment physically connected to the Cab radio within 30 seconds. (M)
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  functionalNumbers : List String
  items             : List String
  deriving DecidableEq, Repr

structure Output where
  registeredNumbers : List String
  elapsedMicros    : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functionalNumbers.length ≤ 10 ∧ i.items.length ≤ 10
  post := fun i o => o.registeredNumbers.length = i.functionalNumbers.length ∧
                     o.elapsedMicros ≤ 30000000

example : Spec.pre { functionalNumbers := ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"],
                     items := ["item1", "item2", "item3", "item4", "item5", "item6", "item7", "item8", "item9", "item10"] } ∧
          Spec.post { functionalNumbers := ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"],
                      items := ["item1", "item2", "item3", "item4", "item5", "item6", "item7", "item8", "item9", "item10"],
                      elapsedMicros := 29000000 } := by
  unfold Spec; decide
