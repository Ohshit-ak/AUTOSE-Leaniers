import ContractForge
open ContractForge

-- 3.2.2.2/S3: The TCS shall receive, process, and present payload data to the operator so that the status of the payload can be determined. [SSS151]
-- compiles: False · rejects_bad_example: None · checked: False

structure Payload where
  status : String
  deriving DecidableEq, Repr

structure Input where
  payloadData : List Payload
  deriving DecidableEq, Repr

structure Output where
  status : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.payloadData.Nodup
  post := fun i o => o.status = i.payloadData.map (fun p => p.status).head

example : Spec.pre { payloadData := [{ status := "active" }, { status := "inactive" }] } ∧
          Spec.post { payloadData := [{ status := "active" }, { status := "inactive" }] }
                    { status := "active" } := by
  unfold Spec; decide
