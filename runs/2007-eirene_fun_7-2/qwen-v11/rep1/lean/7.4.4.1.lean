import ContractForge
open ContractForge

-- 7.4.4.1: 7.4.4.1 A visual and audible alarm shall be given when the remaining capacity of the battery is such as to enable only 10 minutes of full duplex call time. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  remainingCapacity : Nat
  elapsedMicros     : Nat
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  visualAlarm   : Bool
  audibleAlarm  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.remainingCapacity
  post := fun i o => (o.visualAlarm = true ∧ o.audibleAlarm = true) ↔
                     (i.remainingCapacity ≤ 10 * 60000) ∧
                     o.elapsedMicros ≤ 600000000

example : Spec.pre { remainingCapacity := 600000, elapsedMicros := 599999999 } ∧
          Spec.post { remainingCapacity := 600000, elapsedMicros := 599999999 }
                    { visualAlarm := true, audibleAlarm := true, elapsedMicros := 599999999 } := by
  unfold Spec; decide
