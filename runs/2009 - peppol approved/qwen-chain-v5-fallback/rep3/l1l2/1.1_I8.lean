import ContractForge
open ContractForge

-- 1.1/I8: Article 46 - suitability to pursue a professional activity: e.g. certificate of registration from thecommercial register

-- L0 spec

structure Input where
  registrationCertificate : String
  deriving DecidableEq, Repr

structure Output where
  suitable : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.registrationCertificate ≠ ""
  post := fun i o => o.suitable = true ↔
    i.registrationCertificate.toList.all Char.isAlphanum = true

example : Spec.pre { registrationCertificate := "1234567890" } ∧
          Spec.post { registrationCertificate := "1234567890" }
                    { suitable := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { suitable := decide (x.registrationCertificate.toList.all Char.isAlphanum = true) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
