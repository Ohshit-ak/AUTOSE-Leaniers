import ContractForge
open ContractForge

-- 3.8.2/S1: The network shall send the SET-PARAMETER message with the attribute "D-ATT = T"1 [EN 301 515, Index [6]] to the mobile station of the talking subscriber if it receives the 3- digit sequence "###" transmitted via DTMF or the group call SETUP message2 from a controller terminal.

-- L0 spec

structure Input where
  sequence : String
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  deriving DecidableEq, Repr

-- IMPL: The network sends the SET-PARAMETER message with the attribute "D-ATT = T" to the mobile station.

def Spec : Contract Input Output where
  pre  := fun i => i.sequence.length = 3 ∧ i.sequence.toList.all Char.isDigit = true
  post := fun i o => o.sent = true ↔
    (i.sequence = "###" ∨
     (∃ msg ∈ [i.sequence], msg = "group call SETUP message" ∧
      ∃ ctrl ∈ [i.sequence], ctrl = "controller terminal"))

example : Spec.pre { sequence := "111" } ∧ Spec.post { sequence := "111" } { sent := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { sent := decide ((x.sequence = "###" ∨
     (∃ msg ∈ [x.sequence], msg = "group call SETUP message" ∧
      ∃ ctrl ∈ [x.sequence], ctrl = "controller terminal"))) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
