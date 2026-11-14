import ContractForge
open ContractForge

-- 13.4.3: 13.4.3 The confirmation message shall commence at the end of the call or if the radio moves out of the call area. (M)

-- L0 spec

structure Call where
  callStarted : Bool
  deriving DecidableEq, Repr

structure Input where
  callStarted : Bool
  radioMoved  : Bool
  deriving DecidableEq, Repr

structure Output where
  confirmationMessage : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callStarted
  post := fun i o => o.confirmationMessage = true ↔
    (i.callStarted = true ∧ i.radioMoved = false) ∨
    (i.callStarted = false ∧ i.radioMoved = true)

example : Spec.pre { callStarted := true, radioMoved := false } ∧ Spec.post { callStarted := true, radioMoved := false } { confirmationMessage := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { confirmationMessage := decide ((x.callStarted = true ∧ x.radioMoved = false) ∨
    (x.callStarted = false ∧ x.radioMoved = true)) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
