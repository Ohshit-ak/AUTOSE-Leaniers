import ContractForge
open ContractForge

-- 2.5.9/S1: Systems supporting OM must be able to receive, parse and process messages for countermeasures that have been administered.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { processed := decide (x.countermeasures.all (fun cm => 
      ∃ cm' ∈ x.countermeasures, cm.id = cm'.id ∧
      cm.patient = cm'.patient ∧
      cm.dose = cm'.dose ∧
      cm.adminDate = cm'.adminDate)) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
