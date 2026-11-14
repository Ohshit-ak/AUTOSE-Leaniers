import ContractForge
open ContractForge

-- 3.3.2.4/S3: If an economic operator decides to participate in a particular procurement procedure he can directly retrieve the relevant criteria by using the information published in the contract notice.

-- L0 spec

structure Input where
  criteria : List String
  deriving DecidableEq, Repr

structure Output where
  retrieved : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.criteria ≠ []
  post := fun i o => o.retrieved = i.criteria ∧
                     (o.retrieved.length = i.criteria.length) ∧
                     (∀ c ∈ o.retrieved, c ∈ i.criteria)

example : Spec.pre { criteria := ["technical", "financial"] } ∧
          Spec.post { criteria := ["technical", "financial"] } { retrieved := ["technical", "financial"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { retrieved := x.criteria }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
