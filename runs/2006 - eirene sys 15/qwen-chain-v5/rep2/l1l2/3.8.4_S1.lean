import ContractForge
open ContractForge

-- 3.8.4/S1: The network shall send the SET-PARAMETER message with the attribute "D-ATT = F"3 [EN 301 515, Index [6]] to the mobile of the talking subscriber only if it has received the 3-digit sequence "#**" transmitted via DTMF from all the talking controllers4.

-- L0 spec

structure Input where
  dtmfSequence : String
  talkingControllers : List String
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  deriving DecidableEq, Repr

-- IMPL: DTMF sequence processing

def Spec : Contract Input Output where
  pre  := fun i => i.dtmfSequence.length = 3 ∧ i.dtmfSequence.toList.all (fun c => c == '*')
  post := fun i o => o.sent = true ↔
    i.talkingControllers.length = 0 ∨
    (∀ c ∈ i.talkingControllers, i.dtmfSequence = "#**" ∧ o.sent = true)

example : Spec.pre { dtmfSequence := "***", talkingControllers := [] } ∧
          Spec.post { dtmfSequence := "***", talkingControllers := [] }
                    { sent := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { sent := x.talkingControllers.length = 0 ∨
            (∀ c ∈ x.talkingControllers, x.dtmfSequence = "#**") }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
