import ContractForge
open ContractForge

-- 4.3.1/S1#2: The piloting phase of the Austrian VCD implementation will include several selected stakeholders, which take up key positions in the Austrian procurement landscape.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { stakeholders := x.stakeholders }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
