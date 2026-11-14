import ContractForge
open ContractForge

-- 14.4.3/S1: The terminal application shall prevent members of a dedicated shunting team from initiating a new call (unless they are registered as shunting team leader and have left shunting mode using the "maintain group call" function described in 14.2.4).

-- L0 spec

structure Input where
  shuntingTeamLeader : Bool
  inShuntingMode     : Bool
  initiatingCall     : Bool
  deriving DecidableEq, Repr

structure Output where
  allowedToInitiate : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.initiatingCall = true
  post := fun i o => (o.allowedToInitiate = true ↔
    (i.shuntingTeamLeader = true ∧ i.inShuntingMode = false)) ∨
    (o.allowedToInitiate = false ↔
    (i.shuntingTeamLeader = false ∨ i.inShuntingMode = true))

example : Spec.pre { shuntingTeamLeader := false, inShuntingMode := true, initiatingCall := true } ∧
          Spec.post { shuntingTeamLeader := false, inShuntingMode := true, initiatingCall := true }
                    { allowedToInitiate := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { allowedToInitiate := decide (x.shuntingTeamLeader = true ∧ x.inShuntingMode = false) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
