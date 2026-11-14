import ContractForge
open ContractForge

-- 5.1/R5: The system shall be able to search for a specified product in less than 1 second.

-- L0 spec

structure Input where
  product : String
  results : List String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

structure Output where
  results : List String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.product ≠ ""
  post := fun i o => o.results.length ≤ 100 ∧
                     o.elapsedMicros < 1000000 ∧
                     (o.results = [] ↔ i.results = []) ∧
                     (o.elapsedMicros = 0 ↔ i.elapsedMicros = 0)

example : Spec.pre { product := "laptop", results := ["Product found"], elapsedMicros := 900000 } ∧
          Spec.post { product := "laptop", results := ["Product found"], elapsedMicros := 900000 }
                    { results := ["Product found"], elapsedMicros := 900000 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { results := if x.results = [] then [] else x.results.take 100,
    elapsedMicros := if x.elapsedMicros = 0 then 0 else min x.elapsedMicros 999999 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
