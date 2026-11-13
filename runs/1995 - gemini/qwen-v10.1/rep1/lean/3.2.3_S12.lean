import ContractForge
open ContractForge

-- 3.2.3/S12: In practice the operation and facilities foreseen so far for the Gemini 8m Telescopes will limit this number to a maximum in the order of three active nodes, but the Gemini 8m Telescopes computers and software shall be capable of coping with the load of 10 active nodes, should the case arise
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  activeNodes : Nat
  deriving DecidableEq, Repr

structure Output where
  handling : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.activeNodes ≤ 3
  post := fun i o => o.handling = true ↔ i.activeNodes ≤ 10

example : Spec.pre { activeNodes := 2 } ∧
          Spec.post { activeNodes := 2 } { handling := true } := by
  unfold Spec; decide
