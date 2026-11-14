import ContractForge
open ContractForge

-- 5.6.2/S1: As a train approaches the limits of the coverage of the PLMN it is registered with, it will be necessary for it to register with the next PLMN providing coverage.

-- L0 spec

structure Input where
  currentPLMN : String
  nextPLMN    : String
  deriving DecidableEq, Repr

structure Output where
  registeredPLMN : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.currentPLMN ≠ "" ∧ i.nextPLMN ≠ ""
  post := fun i o => o.registeredPLMN = i.nextPLMN

example : Spec.pre { currentPLMN := "PLMN123", nextPLMN := "PLMN456" } ∧
          Spec.post { currentPLMN := "PLMN123", nextPLMN := "PLMN456" }
                    { registeredPLMN := "PLMN456" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { registeredPLMN := x.nextPLMN }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
