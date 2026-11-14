import ContractForge
open ContractForge

-- 15.2.3/S1: Direct mode equipment shall have a maximum transmit power of 1 Watt.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  transmitPower : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔ i.transmitPower ≤ 1000

example : Spec.pre { transmitPower := 500 } ∧
          Spec.post { transmitPower := 500 }
                    { valid := true } := by
  unfold Spec; decide
