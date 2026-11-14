import ContractForge
open ContractForge

-- 3.2.3/S12: In practice the operation and facilities foreseen so far for the Gemini 8m Telescopes will limit this number to a maximum in the order of three active nodes, but the Gemini 8m Telescopes computers and software shall be capable of coping with the load of 10 active nodes, should the case arise
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  activeNodes : Nat
  maxCapacity : Nat := 10
  deriving DecidableEq, Repr

structure Output where
  activeNodes : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 ≤ i.activeNodes ∧ i.activeNodes ≤ 3
  post := fun i o => o.activeNodes = i.activeNodes ∧
                     (o.activeNodes ≤ i.maxCapacity ↔ i.activeNodes ≤ 10)

example : Spec.pre { activeNodes := 2, maxCapacity := 10 } ∧
          Spec.post { activeNodes := 2, maxCapacity := 10 } { activeNodes := 2 } := by
  unfold Spec; decide
