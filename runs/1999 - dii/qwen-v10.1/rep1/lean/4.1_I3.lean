import ContractForge
open ContractForge

-- 4.1/I3: In the fixed (static) mode of operation (base or data processing megacenter), the data management services shall have the capability of being tuned by on-site personnel to adjust for varying workloads and sizes of associated databases. These workloads and databases are expected to change more frequently and to a greater extent than for processing associated with deployed units
-- compiles: True · rejects_bad_example: True · checked: True

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
