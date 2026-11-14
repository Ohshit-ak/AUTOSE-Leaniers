import ContractForge
open ContractForge

-- 3.3.2.12/S6: Requirement A trust model and trust system MUST be defined from a legal point of view for every process which includes the roles and responsibilities of the entities involved.

-- L0 spec

structure Input where
  roles : List String
  responsibilities : List String
  deriving DecidableEq, Repr

structure Output where
  trustModelDefined : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.roles ≠ [] ∧ i.responsibilities ≠ []
  post := fun i o => o.trustModelDefined = true ∧
                     (o.trustModelDefined = true ↔ i.roles ≠ [] ∧ i.responsibilities ≠ [])

example : Spec.pre { roles := ["Entity A", "Entity B"], responsibilities := ["Role 1", "Role 2"] } ∧
          Spec.post { roles := ["Entity A", "Entity B"], responsibilities := ["Role 1", "Role 2"] }
                    { trustModelDefined := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { trustModelDefined := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
