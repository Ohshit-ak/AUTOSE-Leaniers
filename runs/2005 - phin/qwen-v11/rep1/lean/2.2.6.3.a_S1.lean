import ContractForge
open ContractForge

-- 2.2.6.3.a/S1: Clinical specimen data should include information about the specimen source/site from which the specimen was taken, symptom date of onset, and whether the sample is acute or convalescent.
-- compiles: True · rejects_bad_example: None · checked: True

structure Specimen where
  source  : String
  symptomDate : Nat
  isAcute : Bool
  deriving DecidableEq, Repr

structure Input where
  specimen : Specimen
  deriving DecidableEq, Repr

structure Output where
  source  : String
  symptomDate : Nat
  isAcute : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.source = i.specimen.source ∧
                     o.symptomDate = i.specimen.symptomDate ∧
                     o.isAcute = i.specimen.isAcute

example : Spec.pre { specimen := { source := "nose", symptomDate := 5, isAcute := true } } ∧
          Spec.post { specimen := { source := "nose", symptomDate := 5, isAcute := true } }
                    { source := "nose", symptomDate := 5, isAcute := true } := by
  unfold Spec; decide
