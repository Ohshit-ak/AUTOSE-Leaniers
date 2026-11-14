import ContractForge
open ContractForge

-- 2.4/S4: When a signal is sent to a heating or cooling unit, no signal shall be available to allow the THEMAS system to determine if the signal sent to the unit was realized by the unit.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  signalSent : Bool
  signalRealized : Bool
  deriving DecidableEq, Repr

structure Output where
  signalSent : Bool
  signalRealized : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signalSent
  post := fun i o => o.signalSent = i.signalSent ∧
                     o.signalRealized = false ∧
                     (o.signalSent = true ↔ i.signalSent = true)

example : Spec.pre { signalSent := true, signalRealized := false } ∧
          Spec.post { signalSent := true, signalRealized := false }
                    { signalSent := true, signalRealized := false } := by
  unfold Spec; decide
