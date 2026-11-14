import ContractForge
open ContractForge

-- 4.2/S10: Since the VCD implementation also touches national demands for existing infrastructures to access and retrieve evidences from issuing bodies (see the lower part of Country A in Figure 21), such infrastructures and required identity and access management for accessing local issuing bodies are considered as parts of national infrastructures where PEPPOL will embark on.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  evidences : List String
  issuingBodies : List String
  identityManagement : Bool
  accessManagement : Bool
  deriving DecidableEq, Repr

structure Output where
  evidencesRetrieved : List String
  accessGranted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.identityManagement = true ∧ i.accessManagement = true
  post := fun i o => (o.accessGranted = true ↔
    ∃ e ∈ i.evidences, ∃ b ∈ i.issuingBodies, o.evidencesRetrieved.contains e ∧
    (i.identityManagement = true → o.accessGranted = true)) ∧
    o.evidencesRetrieved.length ≤ i.evidences.length

example : Spec.pre { evidences := ["e1", "e2"], issuingBodies := ["b1", "b2"],
                     identityManagement := true, accessManagement := true } ∧
          Spec.post { evidences := ["e1", "e2"], issuingBodies := ["b1", "b2"],
                      identityManagement := true, accessManagement := true }
                    { evidencesRetrieved := ["e1"], accessGranted := true } := by
  unfold Spec; decide
