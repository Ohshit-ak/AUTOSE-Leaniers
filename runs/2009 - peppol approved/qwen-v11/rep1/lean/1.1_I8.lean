import ContractForge
open ContractForge

-- 1.1/I8: Article 46 - suitability to pursue a professional activity: e.g. certificate of registration from thecommercial register
-- compiles: True · rejects_bad_example: True · checked: True

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
