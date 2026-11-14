import ContractForge
open ContractForge

-- 0/S5: The following description responds to these comments and criticism by arguing how and where revisions and updates of the work presented in this deliverable will be implemented in subsequent results of WP 2.

-- L0 spec

structure Input where
  revisions : List String
  updates   : List String
  deriving DecidableEq, Repr

structure Output where
  implemented : Bool
  deriving DecidableEq, Repr

-- IMPL: The revisions and updates will be implemented in subsequent results of WP 2 by checking if the revisions and updates are present in the input.

def Spec : Contract Input Output where
  pre  := fun _ => true
  post := fun i o => o.implemented = true ↔
    (i.revisions.Nodup ∧ i.updates.Nodup) ∧
    (i.revisions.length + i.updates.length > 0)

example : Spec.pre { revisions := ["rev1", "rev2"], updates := ["up1"] } ∧
          Spec.post { revisions := ["rev1", "rev2"], updates := ["up1"] }
                    { implemented := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { implemented := decide ((x.revisions.Nodup ∧ x.updates.Nodup) ∧
    (x.revisions.length + x.updates.length > 0)) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
