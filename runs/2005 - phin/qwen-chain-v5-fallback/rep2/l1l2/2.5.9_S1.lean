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
  countermeasures : List Countermeasure
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.countermeasures.Nodup
  post := fun i o => o.processed = true ∧
    (o.processed = false → o.countermeasures = i.countermeasures) ∧
    (∃ cm ∈ i.countermeasures, o.processed = true →
      o.countermeasures.contains cm ∧
      o.countermeasures.count cm = i.countermeasures.count cm)

example : Spec.pre { countermeasures := [{ id := 1, patient := "P1", dose := 100, adminDate := "2023-01-01" }] } ∧
          Spec.post { countermeasures := [{ id := 1, patient := "P1", dose := 100, adminDate := "2023-01-01" }] }
                    { processed := true, countermeasures := [{ id := 1, patient := "P1", dose := 100, adminDate := "2023-01-01" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { processed := true,
    countermeasures := x.countermeasures }
