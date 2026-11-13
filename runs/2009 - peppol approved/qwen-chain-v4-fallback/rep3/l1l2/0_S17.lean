import ContractForge
open ContractForge

-- 0/S17: In reference to this, D2.2 will comprise a short overview of the updated state of practice and the relation to current more detailed results of WP2.

-- L0 spec

structure Input where
  deriving DecidableEq, Repr

structure Output where
  overview : String
  relation : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.overview ≠ "" ∧ o.relation ≠ ""

example : Spec.pre {} ∧ Spec.post {} { overview := "Short overview of the updated state of practice.", relation := "Relation to current more detailed results of WP2." } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { overview := "Short overview of the updated state of practice.", relation := "Relation to current more detailed results of WP2." }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
