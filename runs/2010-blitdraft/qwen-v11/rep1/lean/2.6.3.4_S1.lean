import ContractForge
open ContractForge

-- 2.6.3.4/S1: The Development Team shall develop and then send out release notes via e-mail to all Project Team after each [SYSTEM NAME] build deployed to the Staging environment.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  buildNotes : String
  projectTeamEmails : List String
  deriving DecidableEq, Repr

structure Output where
  sentToProjectTeam : Bool
  buildNotes : String
  projectTeamEmails : List String
  deriving DecidableEq, Repr

-- IMPL: The release notes are sent via e-mail to the project team after each build.

def Spec : Contract Input Output where
  pre  := fun i => i.buildNotes ≠ "" ∧ i.projectTeamEmails.Nodup
  post := fun i o => o.sentToProjectTeam = true ∧
                     (o.buildNotes = i.buildNotes ∧
                      o.projectTeamEmails = i.projectTeamEmails)

example : Spec.pre { buildNotes := "New features and bug fixes.", projectTeamEmails := ["team1@example.com", "team2@example.com"] } ∧
          Spec.post { buildNotes := "New features and bug fixes.", projectTeamEmails := ["team1@example.com", "team2@example.com"] }
                    { sentToProjectTeam := true, buildNotes := "New features and bug fixes.", projectTeamEmails := ["team1@example.com", "team2@example.com"] } := by
  unfold Spec; decide
