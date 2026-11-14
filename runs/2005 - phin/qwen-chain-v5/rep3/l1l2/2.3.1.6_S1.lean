import ContractForge
open ContractForge

-- 2.3.1.6/S1: Systems supporting OM should track the changes made to the status of case records as a result of changes in the case definition.

-- L0 spec

structure CaseRecord where
  status : String
  deriving DecidableEq, Repr

structure Input where
  originalStatus : String
  newStatus      : String
  deriving DecidableEq, Repr

structure Output where
  originalStatus : String
  newStatus      : String
  statusChanges  : List (String × String)
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.originalStatus ≠ "" ∧ i.newStatus ≠ ""
  post := fun i o => o.originalStatus = i.originalStatus ∧
                     o.newStatus = i.newStatus ∧
                     o.statusChanges.length = 1 ∧
                     o.statusChanges.contains (i.originalStatus, i.newStatus)

example : Spec.pre { originalStatus := "open", newStatus := "closed" } ∧
          Spec.post { originalStatus := "open", newStatus := "closed" }
                    { originalStatus := "open", newStatus := "closed", statusChanges := [("open", "closed")] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { originalStatus := x.originalStatus,
    newStatus := x.newStatus,
    statusChanges := [(x.originalStatus, x.newStatus)] }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
