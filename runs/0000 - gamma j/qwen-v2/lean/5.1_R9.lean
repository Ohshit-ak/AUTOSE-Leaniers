-- 5.1/R9: The system shall be able to restore 1000 records per second.
-- checked: True

structure Input where
  recordsToRestore : Nat
  deriving DecidableEq, Repr

structure Output where
  perSecond : Nat
  restored  : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.recordsToRestore
  post := fun i o => o.restored = i.recordsToRestore ∧
                     o.perSecond ≥ 1000

example : Spec.pre { recordsToRestore := 1000 } ∧
          Spec.post { recordsToRestore := 1000 }
                     { perSecond := 1050, restored := 1000 } := by
  unfold Spec; decide
