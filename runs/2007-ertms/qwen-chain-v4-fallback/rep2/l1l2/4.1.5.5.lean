import ContractForge
open ContractForge

-- 4.1.5.5: The trainborne equipment shall remain in Full Supervision until the trainborne equipment is not active any longer, when Shunting is selected or when Partial Supervision information is received.

-- L0 spec

structure Input where
  active : Bool
  shuntingSelected : Bool
  partialSupervisionInfoReceived : Bool
  deriving DecidableEq, Repr

structure Output where
  fullSupervision : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.active
  post := fun i o => (o.fullSupervision = true ↔ i.active) ∧
                     (o.fullSupervision = false ↔
                      (i.shuntingSelected ∧ i.active) ∨
                      (i.partialSupervisionInfoReceived ∧ i.active))

example : Spec.pre { active := true, shuntingSelected := false, partialSupervisionInfoReceived := false } ∧ Spec.post { active := true, shuntingSelected := false, partialSupervisionInfoReceived := false } { fullSupervision := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { fullSupervision := decide (x.active) }
