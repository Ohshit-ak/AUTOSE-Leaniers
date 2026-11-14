import ContractForge
open ContractForge

-- Design Constraints/S3#2: On capture of any duplicate name the system will give a warning message to have the duplicate name or to change the name.

-- L0 spec

structure Input where
  names : List String
  deriving DecidableEq, Repr

structure Output where
  warnings : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.names.Nodup
  post := fun i o => o.warnings.length ≤ i.names.length ∧
                     (∀ w ∈ o.warnings, ∃ n ∈ i.names, w = "Duplicate name: " ++ n)

example : Spec.pre { names := [] } ∧ Spec.post { names := [] } { warnings := [] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { warnings := (x.names.filter (fun w => decide (∃ n ∈ x.names, w = "Duplicate name: " ++ n))).take x.names.length }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
