import ContractForge
open ContractForge

-- 2.3.1.5/S1: Systems supporting OM should provide a manual or automatic means of updating the status of case records as the case definition changes.

-- L0 spec

structure CaseRecord where
  status : String
  notes  : String
  deriving DecidableEq, Repr

structure Input where
  records : List CaseRecord
  newStatus : String
  deriving DecidableEq, Repr

structure Output where
  updatedRecords : List CaseRecord
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.records.Nodup
  post := fun i o => o.updatedRecords = i.records.map (fun cr => { cr with status := i.newStatus }) ∧
                     o.updatedRecords.length = i.records.length

example : Spec.pre { records := [{ status := "open", notes := "initial" }],
                     newStatus := "closed" } ∧
          Spec.post { records := [{ status := "open", notes := "initial" }],
                      newStatus := "closed" }
                    { updatedRecords := [{ status := "closed", notes := "initial" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { updatedRecords := x.records.map (fun cr => { cr with status := x.newStatus }) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
