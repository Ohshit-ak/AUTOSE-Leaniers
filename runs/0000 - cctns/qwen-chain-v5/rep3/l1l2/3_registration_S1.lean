import ContractForge
open ContractForge

-- 3/registration/S1: Citizens can register their complaints with police and then based on the evidence, facts and following investigation, police shall take the complaint forward.

-- L0 spec

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
     o.status = "New" ↔ o.accepted = true) ∧
    (o.accepted = false →
      o.complaintID = i.complaint.complaintID ∧
      o.status = "Rejected" ∧
      i.evidence.all (fun e => e ∉ i.complaint.evidence))

example : Spec.pre { citizenID := 1, complaint := { complaintID := 1, description := "Theft", evidence := ["eye-witness", "video"], status := "New" }, evidence := ["eye-witness", "video"] } ∧
          Spec.post { citizenID := 1, complaint := { complaintID := 1, description := "Theft", evidence := ["eye-witness", "video"], status := "New" }, evidence := ["eye-witness", "video"] }
                    { accepted := true, complaintID := 1, status := "New" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  complaintID : Nat
  status      : String
  accepted    : Bool
  evidence : List String
  complaint : Complaint
  deriving DecidableEq, Repr

def ComputeComplaintContract : Contract Input Mid where
  pre  := fun i => i.citizenID ≠ 0 ∧ i.complaint.description ≠ "" ∧ i.evidence.Nodup
  post := fun i m => (m.complaintID = i.complaint.complaintID ∧
                     m.status = "New" ↔ m.accepted = true ∧
                     m.accepted = true →
                     i.evidence.all (fun e => e ∈ i.complaint.evidence)) ∧ m.evidence = i.evidence ∧ m.complaint = i.complaint

def ProcessComplaintContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.complaintID = m.complaintID ∧
                     o.status = "New" ↔ m.accepted = true ∧
                     o.accepted = false →
                     o.complaintID = m.complaintID ∧
                     o.status = "Rejected" ∧
                     m.evidence.all (fun e => e ∉ m.complaint.evidence)


