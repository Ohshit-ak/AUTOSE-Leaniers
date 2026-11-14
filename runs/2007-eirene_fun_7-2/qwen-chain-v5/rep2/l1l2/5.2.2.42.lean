import ContractForge
open ContractForge

-- 5.2.2.42: 5.2.2.42 The Cab radio shall be capable of being used as a standard telephone, such that the driver is able to call any valid number subject to pre-defined call restrictions. The call may be initiated by: (M) selection from a pre-defined list (up to 99 entries); direct dialling a subscriber number; calling a functional number. Receive incoming point-to-point voice call

-- L0 spec

structure Input where
  callList : List String
  deriving DecidableEq, Repr

structure Output where
  callInitiated : Bool
  callNumber : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callList.length ≤ 99
  post := fun i o => o.callInitiated = true ↔
    (i.callList.length > 0 ∧ i.callList.headD "" = o.callNumber) ∨
    (o.callNumber ≠ "" ∧ o.callNumber.length ≤ 10) ∨
    (o.callNumber = "functionalNumber")

example : Spec.pre { callList := ["1234567890", "1234567891"] } ∧
          Spec.post { callList := ["1234567890", "1234567891"] }
                    { callInitiated := true, callNumber := "1234567890" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { callInitiated := x.callList.length > 0,
    callNumber := if x.callList.length > 0 then x.callList.headD "" else "" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
