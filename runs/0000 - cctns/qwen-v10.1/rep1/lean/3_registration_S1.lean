import ContractForge
open ContractForge

-- 3/registration/S1: Citizens can register their complaints with police and then based on the evidence, facts and following investigation, police shall take the complaint forward.
-- compiles: True · rejects_bad_example: True · checked: True

structure Complaint where
  complaintID : Nat
  description : String
  evidence    : List String
  status     : String
  deriving DecidableEq, Repr

structure Input where
  citizenID : Nat
  complaint  : Complaint
  evidence   : List String
  deriving DecidableEq, Repr

structure Output where
  accepted  : Bool
  complaintID : Nat
  status     : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.citizenID ≠ 0 ∧ i.complaint.description ≠ "" ∧ i.evidence.Nodup
  post := fun i o =>
    (o.accepted = true ↔
      i.complaint.status = "New" ∧
      i.evidence.all (fun e => e ∈ i.complaint.evidence)) ∧
    (o.complaintID = i.complaint.complaintID ∧
     o.status = "Under investigation" ∧
     (o.accepted = true → i.complaint.status = "New")) ∧
    (o.accepted = false →
      ∃ e ∈ i.evidence, e ∉ i.complaint.evidence)

example : Spec.pre { citizenID := 1, complaint := { complaintID := 1, description := "Theft", evidence := ["eye witness", "video"], status := "New" }, evidence := ["eye witness", "video"] } ∧
          Spec.post { citizenID := 1, complaint := { complaintID := 1, description := "Theft", evidence := ["eye witness", "video"], status := "New" }, evidence := ["eye witness", "video"] }
                    { accepted := true, complaintID := 1, status := "Under investigation" } := by
  unfold Spec; decide
