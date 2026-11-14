import ContractForge
open ContractForge

-- 4.2/S10: Since the VCD implementation also touches national demands for existing infrastructures to access and retrieve evidences from issuing bodies (see the lower part of Country A in Figure 21), such infrastructures and required identity and access management for accessing local issuing bodies are considered as parts of national infrastructures where PEPPOL will embark on.

-- L0 spec

structure Input where
  evidences : List String
  deriving DecidableEq, Repr

structure Output where
  retrieved : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.evidences.Nodup
  post := fun i o => o.retrieved = true ↔
    ∃ e ∈ i.evidences, e ≠ ""

example : Spec.pre { evidences := ["e1", "e2"] } ∧
          Spec.post { evidences := ["e1", "e2"] }
                    { retrieved := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { retrieved := decide (∃ e ∈ x.evidences, e ≠ "") }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
