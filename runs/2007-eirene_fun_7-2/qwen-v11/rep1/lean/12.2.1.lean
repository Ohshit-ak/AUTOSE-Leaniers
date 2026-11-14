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
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.groundMessage ≠ "" ∧ i.mobileNumbers.Nodup
  post := fun i o => o.sentMessages.length = i.mobileNumbers.length ∧
                     (∀ m ∈ i.mobileNumbers, o.sentMessages.contains m ↔
                      m.length = 11 ∧ m.all Char.isDigit = true) ∧
                     (∀ m ∈ o.sentMessages, ∃ n ∈ i.mobileNumbers, m = n)

example : Spec.pre { groundMessage := "Hello", mobileNumbers := [] } ∧ Spec.post { groundMessage := "Hello", mobileNumbers := [] } { sentMessages := [] } := by
  unfold Spec; decide
