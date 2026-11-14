import ContractForge
open ContractForge

-- 4.1/I3: In the fixed (static) mode of operation (base or data processing megacenter), the data management services shall have the capability of being tuned by on-site personnel to adjust for varying workloads and sizes of associated databases. These workloads and databases are expected to change more frequently and to a greater extent than for processing associated with deployed units

-- L0 spec

structure Input where
  workload  : Nat
  databaseSize : Nat
  deriving DecidableEq, Repr

structure Output where
  adjusted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.workload ∧ 0 < i.databaseSize
  post := fun i o => o.adjusted = true ↔
    (i.workload ≤ 1000 ∧ i.databaseSize ≤ 1000000) ∨
    (i.workload > 1000 ∧ i.databaseSize > 1000000)

example : Spec.pre { workload := 500, databaseSize := 500000 } ∧
          Spec.post { workload := 500, databaseSize := 500000 }
                    { adjusted := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { adjusted := decide ((x.workload ≤ 1000 ∧ x.databaseSize ≤ 1000000) ∨
    (x.workload > 1000 ∧ x.databaseSize > 1000000)) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
