import ContractForge
open ContractForge

-- 4.1/I3: In the fixed (static) mode of operation (base or data processing megacenter), the data management services shall have the capability of being tuned by on-site personnel to adjust for varying workloads and sizes of associated databases. These workloads and databases are expected to change more frequently and to a greater extent than for processing associated with deployed units

-- L0 spec

structure Input where
  workload  : Nat
  databaseSize : Nat
  deriving DecidableEq, Repr

structure Output where
  tuned : Bool
  workload : Nat
  databaseSize : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.workload ∧ 0 < i.databaseSize
  post := fun i o => o.tuned = true ↔
    (i.workload < 500 → o.workload = i.workload * 2) ∧
    (i.workload ≥ 500 → o.workload = i.workload / 2) ∧
    (i.databaseSize < 1000 → o.databaseSize = i.databaseSize * 2) ∧
    (i.databaseSize ≥ 1000 → o.databaseSize = i.databaseSize / 2) ∧
    o.tuned = false → o.workload = i.workload ∧ o.databaseSize = i.databaseSize ∧
    o.tuned = true → o.workload ≠ i.workload ∧ o.databaseSize ≠ i.databaseSize

example : Spec.pre { workload := 300, databaseSize := 500 } ∧ Spec.post { workload := 300, databaseSize := 500 } { tuned := true, workload := 600, databaseSize := 1000 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { tuned := (x.workload < 500) ≠ (x.databaseSize < 1000),
    workload := if x.workload < 500 then x.workload * 2 else x.workload / 2,
    databaseSize := if x.databaseSize < 1000 then x.databaseSize * 2 else x.databaseSize / 2 }
