import ContractForge
open ContractForge

-- 5.6.3/S1: A means of directed network selection should be provided to ensure that the MS registers with the required network.

-- L0 spec

structure Input where
  networkSelection : String
  deriving DecidableEq, Repr

structure Output where
  registered : Bool
  network    : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.networkSelection ≠ ""
  post := fun i o => (o.registered = true ↔ o.network = i.networkSelection) ∧
                     (o.registered = false → o.network = "")

example : Spec.pre { networkSelection := "10.0.0.1" } ∧
          Spec.post { networkSelection := "10.0.0.1" }
                    { registered := true, network := "10.0.0.1" } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { registered := true, network := x.networkSelection }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
