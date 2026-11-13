import ContractForge
open ContractForge

-- 5.2.2.42: 5.2.2.42 The Cab radio shall be capable of being used as a standard telephone, such that the driver is able to call any valid number subject to pre-defined call restrictions. The call may be initiated by: (M) selection from a pre-defined list (up to 99 entries); direct dialling a subscriber number; calling a functional number. Receive incoming point-to-point voice call

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { initiated := decide (x.callList.contains x.subscriberNumber ∧ x.callList.count x.subscriberNumber ≤ 99 ∨
                         (x.subscriberNumber ≠ "" ∧ x.callList.count x.subscriberNumber = 0) ∨
                         (x.functionalNumber ≠ "" ∧ x.callList.count x.functionalNumber = 0)) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
