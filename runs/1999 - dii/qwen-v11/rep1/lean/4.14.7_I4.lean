import ContractForge
open ContractForge

-- 4.14.7/I4: COE Chief Engineer's Role. The COE Chief Engineer will approve a single Point of Contact (POC) for a COI to manage the tags within that COI. The COE Chief Engineer will reserve ultimate authority to mediate any unresolved disputes within all COIs.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  coeChiefEngineerApproval : Bool
  pocForCOI               : String
  disputesMediationRight : Bool
  deriving DecidableEq, Repr

structure Output where
  pocForCOI               : String
  disputesMediationRight : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.coeChiefEngineerApproval = true
  post := fun i o => o.pocForCOI = i.pocForCOI ∧
                     o.disputesMediationRight = i.disputesMediationRight ∧
                     (o.disputesMediationRight = true ↔ i.disputesMediationRight = true)

example : Spec.pre { coeChiefEngineerApproval := true, pocForCOI := "John Doe", disputesMediationRight := true } ∧
          Spec.post { coeChiefEngineerApproval := true, pocForCOI := "John Doe", disputesMediationRight := true }
                     { pocForCOI := "John Doe", disputesMediationRight := true } := by
  unfold Spec; decide
