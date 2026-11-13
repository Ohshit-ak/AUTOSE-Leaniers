import ContractForge
open ContractForge

-- 2.6.3.4/S1: The Development Team shall develop and then send out release notes via e-mail to all Project Team after each [SYSTEM NAME] build deployed to the Staging environment.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  buildNotes : String
  projectTeamEmails : List String
  deriving DecidableEq, Repr

structure Output where
  sentTo : List String
  deriving DecidableEq, Repr

-- IMPL: Send e-mail with build notes to the project team after each build is deployed to the Staging environment.

def Spec : Contract Input Output where
  pre  := fun i => i.buildNotes ≠ "" ∧ i.projectTeamEmails.Nodup
  post := fun i o => o.sentTo = i.projectTeamEmails

example : Spec.pre { buildNotes := "New features and bug fixes.", projectTeamEmails := ["alice@example.com", "bob@example.com"] } ∧
          Spec.post { buildNotes := "New features and bug fixes.", projectTeamEmails := ["alice@example.com", "bob@example.com"] }
                    { sentTo := ["alice@example.com", "bob@example.com"] } := by
  unfold Spec; decide
