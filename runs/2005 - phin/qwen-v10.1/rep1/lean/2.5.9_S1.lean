import ContractForge
open ContractForge

-- 2.5.9/S1: Systems supporting OM must be able to receive, parse and process messages for countermeasures that have been administered.
-- compiles: True · rejects_bad_example: True · checked: True

structure Countermeasure where
  id       : Nat
  patient  : String
  dose     : Nat
  adminDate: String
  deriving DecidableEq, Repr

structure Message where
  countermeasures : List Countermeasure
  deriving DecidableEq, Repr

structure Input where
  countermeasures : List Countermeasure
  deriving DecidableEq, Repr

structure Output where
  processed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.countermeasures.Nodup
  post := fun i o => o.processed = true ↔
    i.countermeasures.all (fun cm => 
      ∃ cm' ∈ i.countermeasures, cm.id = cm'.id ∧
      cm.patient = cm'.patient ∧
      cm.dose = cm'.dose ∧
      cm.adminDate = cm'.adminDate)

example : Spec.pre { countermeasures := [{ id := 1, patient := "P1", dose := 100, adminDate := "2023-01-01" }] } ∧
          Spec.post { countermeasures := [{ id := 1, patient := "P1", dose := 100, adminDate := "2023-01-01" }] }
                    { processed := true } := by
  unfold Spec; decide
