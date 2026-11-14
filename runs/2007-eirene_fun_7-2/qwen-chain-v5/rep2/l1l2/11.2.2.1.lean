import ContractForge
open ContractForge

-- 11.2.2.1: 11.2.2.1 Functional numbers must be unique within the domain of operation. Since the number must be independent of networks, each number must be unique across all networks (including implementation of EIRENE facilities on public networks). (M)

-- L0 spec

structure Input where
  functionalNumber : String
  allNetworks      : List String
  deriving DecidableEq, Repr

structure Output where
  unique : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functionalNumber.length = 16 ∧
                   i.functionalNumber.toList.all (· ≠ '0') = true
  post := fun i o => (o.unique = true ↔
    ∃ fn ∈ i.allNetworks, fn = i.functionalNumber) ∧
                     (o.unique = false ↔
    ∀ fn ∈ i.allNetworks, fn ≠ i.functionalNumber)

example : Spec.pre { functionalNumber := "a1a1a1a1a1a1a1a1", allNetworks := ["1234567890123456", "7890123456789012"] } ∧ Spec.post { functionalNumber := "a1a1a1a1a1a1a1a1", allNetworks := ["1234567890123456", "7890123456789012"] } { unique := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { unique := decide (∃ fn ∈ x.allNetworks, fn = x.functionalNumber) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
