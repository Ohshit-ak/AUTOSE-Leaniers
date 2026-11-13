import ContractForge
open ContractForge

-- 3.5.6.2/I2: soft limit switches - the software will detect unsafe areas and halt; the software will allow movement off of soft limits
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  position : Nat
  softLimit : Nat
  deriving DecidableEq, Repr

structure Output where
  halted : Bool
  moved : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.softLimit ∧ i.position < i.softLimit
  post := fun i o => (o.halted = true ↔ i.position = i.softLimit - 1) ∧
                     (o.moved = true ↔ i.position < i.softLimit - 1)

example : Spec.pre { position := 5, softLimit := 10 } ∧
          Spec.post { position := 5, softLimit := 10 }
                    { halted := false, moved := true } := by
  unfold Spec; decide
