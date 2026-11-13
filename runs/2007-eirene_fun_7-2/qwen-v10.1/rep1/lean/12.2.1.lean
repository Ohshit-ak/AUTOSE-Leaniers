import ContractForge
open ContractForge

-- 12.2.1: 12.2.1 It should be possible to transfer text messages between ground and mobile(s) through the EIRENE system. (O)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  groundMessage : String
  mobileNumbers : List String
  deriving DecidableEq, Repr

structure Output where
  sentMessages : List String
  failedNumbers : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.groundMessage ≠ "" ∧ i.mobileNumbers.Nodup
  post := fun i o => (o.sentMessages.length = i.mobileNumbers.length - o.failedNumbers.length) ∧
                     (∀ n ∈ i.mobileNumbers, o.sentMessages.contains n ↔
                      (n = i.groundMessage || o.failedNumbers.contains n))

example : Spec.pre { groundMessage := "Hello", mobileNumbers := [] } ∧ Spec.post { groundMessage := "Hello", mobileNumbers := [] } { sentMessages := [], failedNumbers := ["789"] } := by
  unfold Spec; decide
