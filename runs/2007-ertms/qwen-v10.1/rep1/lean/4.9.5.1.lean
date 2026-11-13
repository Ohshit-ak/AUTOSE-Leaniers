import ContractForge
open ContractForge

-- 4.9.5.1: The ETCS on-board shall be capable of sending to the trackside train integrity information detected by a system outside ETCS
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  integrityInfo : String
  deriving DecidableEq, Repr

structure Output where
  sentToTrackside : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.integrityInfo ≠ ""
  post := fun i o => o.sentToTrackside = true

example : Spec.pre { integrityInfo := "Integrity OK" } ∧
          Spec.post { integrityInfo := "Integrity OK" }
                    { sentToTrackside := true } := by
  unfold Spec; decide
