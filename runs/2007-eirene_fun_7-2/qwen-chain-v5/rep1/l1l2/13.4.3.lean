import ContractForge
open ContractForge

-- 13.4.3: 13.4.3 The confirmation message shall commence at the end of the call or if the radio moves out of the call area. (M)

-- L0 spec

structure Call where
  duration : Nat
  deriving DecidableEq, Repr

structure Input where
  callActive : Bool
  radioMoved : Bool
  duration   : Nat
  deriving DecidableEq, Repr

structure Output where
  confirmation : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callActive
  post := fun i o => o.confirmation = true ↔
    (i.callActive ∧ i.duration > 0) ∨ i.radioMoved

example : Spec.pre { callActive := true, radioMoved := false, duration := 10 } ∧
          Spec.post { callActive := true, radioMoved := false, duration := 10 }
                    { confirmation := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { confirmation := decide ((x.callActive ∧ x.duration > 0) ∨ x.radioMoved) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
