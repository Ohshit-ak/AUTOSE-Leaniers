import ContractForge
open ContractForge

-- 5.7.15/S1: The Cab radio equipment shall be capable of withstanding the following changes to the main and backup power supplies without interrupting normal operation: (M)

-- L0 spec

structure Input where
  mainPower  : String
  backupPower: String
  deriving DecidableEq, Repr

structure Output where
  normalOperation : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mainPower = "M" ∧ i.backupPower = "M"
  post := fun i o => o.normalOperation = true

example : Spec.pre { mainPower := "M", backupPower := "M" } ∧
          Spec.post { mainPower := "M", backupPower := "M" }
                    { normalOperation := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { normalOperation := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
