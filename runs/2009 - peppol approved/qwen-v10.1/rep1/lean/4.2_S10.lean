import ContractForge
open ContractForge

-- 4.2/S10: Since the VCD implementation also touches national demands for existing infrastructures to access and retrieve evidences from issuing bodies (see the lower part of Country A in Figure 21), such infrastructures and required identity and access management for accessing local issuing bodies are considered as parts of national infrastructures where PEPPOL will embark on.
-- compiles: True · rejects_bad_example: True · checked: True

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
