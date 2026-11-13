import ContractForge
open ContractForge

-- 5.2.2.42: 5.2.2.42 The Cab radio shall be capable of being used as a standard telephone, such that the driver is able to call any valid number subject to pre-defined call restrictions. The call may be initiated by: (M) selection from a pre-defined list (up to 99 entries); direct dialling a subscriber number; calling a functional number. Receive incoming point-to-point voice call
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  callList : List String
  subscriberNumber : String
  functionalNumber : String
  deriving DecidableEq, Repr

structure Output where
  initiated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callList.length ≤ 99 ∧ i.subscriberNumber ≠ "" ∧ i.functionalNumber ≠ ""
  post := fun i o => (o.initiated = true ↔
    (i.callList.contains i.subscriberNumber ∧ i.callList.count i.subscriberNumber ≤ 99) ∨
    (i.subscriberNumber ≠ "" ∧ i.callList.count i.subscriberNumber = 0) ∨
    (i.functionalNumber ≠ "" ∧ i.callList.count i.functionalNumber = 0))

example : Spec.pre { callList := ["123456789", "987654321"], subscriberNumber := "123456789",
                     functionalNumber := "987654321" } ∧
          Spec.post { callList := ["123456789", "987654321"], subscriberNumber := "123456789",
                      functionalNumber := "987654321" }
                    { initiated := true } := by
  unfold Spec; decide
