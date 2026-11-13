import ContractForge
open ContractForge

-- 4.2.3.6b: The train shall, as a minimum, be supervised to a ceiling speed; the supervised speed shall not be shown on the DMI unless selected by the driver.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  ceilingSpeed : Nat
  supervisedSpeed : Nat
  deriving DecidableEq, Repr

structure Output where
  dmiDisplay : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.ceilingSpeed
  post := fun i o => (o.dmiDisplay = true ↔ i.supervisedSpeed = i.ceilingSpeed) ∧
                     (o.dmiDisplay = false → i.supervisedSpeed ≠ i.ceilingSpeed)

example : Spec.pre { ceilingSpeed := 60, supervisedSpeed := 50 } ∧
          Spec.post { ceilingSpeed := 60, supervisedSpeed := 50 }
                    { dmiDisplay := false } := by
  unfold Spec; decide
