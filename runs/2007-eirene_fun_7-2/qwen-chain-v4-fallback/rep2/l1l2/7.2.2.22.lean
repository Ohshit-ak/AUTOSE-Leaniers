import ContractForge
open ContractForge

-- 7.2.2.22: 7.2.2.22 If the user moves out of the group or broadcast call area whilst the call is in progress, an audible and visual indication of the loss of call shall be provided to the user. (M) Receive incoming Railway emergency call

-- L0 spec

structure Input where
  userPosition : String
  callActive   : Bool
  callArea     : String
  deriving DecidableEq, Repr

structure Output where
  userPosition : String
  callActive   : Bool
  callArea     : String
  alert        : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callActive = true
  post := fun i o => (o.alert = true ↔
    (i.userPosition ≠ i.callArea ∧ i.callActive = true))

example : Spec.pre { userPosition := "outside", callActive := true, callArea := "inside" } ∧
          Spec.post { userPosition := "outside", callActive := true, callArea := "inside" }
                    { userPosition := "outside", callActive := true, callArea := "inside", alert := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { userPosition := x.userPosition, callActive := x.callActive, callArea := x.callArea, alert := decide (x.userPosition ≠ x.callArea ∧ x.callActive = true) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
