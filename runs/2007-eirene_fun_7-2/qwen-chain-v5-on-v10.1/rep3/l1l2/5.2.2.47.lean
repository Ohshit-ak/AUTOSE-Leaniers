import ContractForge
open ContractForge

-- 5.2.2.47: 5.2.2.47 An audible and visual indication of the incoming call shall be provided when a Cab radio receives a group or broadcast call. (M)

-- L0 spec

structure Input where
  cabId : Nat
  callType : String
  deriving DecidableEq, Repr

structure Output where
  audibleIndication : Bool
  visualIndication : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callType = "group" ∨ i.callType = "broadcast"
  post := fun i o => (o.audibleIndication = true ∧ o.visualIndication = true) ↔
                     (i.callType = "group" ∨ i.callType = "broadcast")

example : Spec.pre { cabId := 1, callType := "group" } ∧
          Spec.post { cabId := 1, callType := "group" }
                    { audibleIndication := true, visualIndication := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { audibleIndication := true, visualIndication := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
