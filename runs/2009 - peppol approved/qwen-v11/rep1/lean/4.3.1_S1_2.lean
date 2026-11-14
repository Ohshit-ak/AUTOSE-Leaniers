import ContractForge
open ContractForge

-- 4.3.1/S1#2: The piloting phase of the Austrian VCD implementation will include several selected stakeholders, which take up key positions in the Austrian procurement landscape.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  stakeholders : List String
  deriving DecidableEq, Repr

structure Output where
  stakeholders : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.stakeholders.Nodup ∧
                  i.stakeholders.length = 3 ∧
                  i.stakeholders.contains "Procurement Agency" ∧
                  i.stakeholders.contains "Supplier A" ∧
                  i.stakeholders.contains "Supplier B"
  post := fun i o => o.stakeholders = i.stakeholders

example : Spec.pre { stakeholders := ["Procurement Agency", "Supplier A", "Supplier B"] } ∧
          Spec.post { stakeholders := ["Procurement Agency", "Supplier A", "Supplier B"] }
                    { stakeholders := ["Procurement Agency", "Supplier A", "Supplier B"] } := by
  unfold Spec; decide
