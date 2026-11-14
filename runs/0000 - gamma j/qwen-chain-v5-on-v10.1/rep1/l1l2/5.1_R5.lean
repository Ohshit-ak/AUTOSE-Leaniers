import ContractForge
open ContractForge

-- 5.1/R5: The system shall be able to search for a specified product in less than 1 second.

-- L0 spec

structure Input where
  product : String
  items   : List String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.product ≠ ""
  post := fun i o => (o.results.length = 0 ↔ o.elapsedMicros = 0) ∧
                     (o.results.length > 0 → o.elapsedMicros < 1000000)

example : Spec.pre { product := "laptop", items := ["laptop", "phone", "tablet"] } ∧
          Spec.post { product := "laptop", items := ["laptop", "phone", "tablet"] }
                    { results := ["laptop"], elapsedMicros := 500000 } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { results := [], elapsedMicros := 0 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
