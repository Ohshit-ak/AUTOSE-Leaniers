import ContractForge
open ContractForge

-- 4.2/S10: Since the VCD implementation also touches national demands for existing infrastructures to access and retrieve evidences from issuing bodies (see the lower part of Country A in Figure 21), such infrastructures and required identity and access management for accessing local issuing bodies are considered as parts of national infrastructures where PEPPOL will embark on.

-- L0 spec

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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  evidencesRetrieved : List String
  identityManagement : Bool
  deriving DecidableEq, Repr

def RetrieveEvidencesContract : Contract Input Mid where
  pre  := fun i => i.identityManagement = true ∧ i.accessManagement = true
  post := fun i m => (m.evidencesRetrieved.length ≤ i.evidences.length ∧
                     (∃ e ∈ i.evidences, ∃ b ∈ i.issuingBodies, m.evidencesRetrieved.contains e)) ∧ m.identityManagement = i.identityManagement

def GrantAccessContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.accessGranted = true ↔
                     (m.evidencesRetrieved.length > 0 ∧
                      (m.identityManagement = true → o.accessGranted = true))


