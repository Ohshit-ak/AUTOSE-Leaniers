import ContractForge
open ContractForge

-- 5.7.15/S1: The Cab radio equipment shall be capable of withstanding the following changes to the main and backup power supplies without interrupting normal operation: (M)

-- L0 spec

structure Input where
  mainPower  : Nat
  backupPower: Nat
  deriving DecidableEq, Repr

structure Output where
  normalOperation : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.mainPower ∧ 0 < i.backupPower
  post := fun i o => (o.normalOperation = true ↔
    (i.mainPower ≠ 0 ∧ i.backupPower ≠ 0)) ∧
    (o.normalOperation = false ↔
    (i.mainPower = 0 ∨ i.backupPower = 0))

example : Spec.pre { mainPower := 120, backupPower := 120 } ∧ Spec.post { mainPower := 120, backupPower := 120 } { normalOperation := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { normalOperation := decide ((x.mainPower ≠ 0 ∧ x.backupPower ≠ 0)) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
