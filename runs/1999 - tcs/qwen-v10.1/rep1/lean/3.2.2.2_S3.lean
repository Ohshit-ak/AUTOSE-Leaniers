import ContractForge
open ContractForge

-- 3.2.2.2/S3: The TCS shall receive, process, and present payload data to the operator so that the status of the payload can be determined. [SSS151]
-- compiles: True · rejects_bad_example: True · checked: True

structure PayloadData where
  status : String
  deriving DecidableEq, Repr

structure Input where
  payloadData : List PayloadData
  deriving DecidableEq, Repr

structure Output where
  presented : List PayloadData
  statusDetermined : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.payloadData.Nodup
  post := fun i o => o.statusDetermined = true ∧
                     (∀ pd ∈ o.presented, pd ∈ i.payloadData ∧
                      pd.status ≠ "" ∧
                      ∃ pdi ∈ i.payloadData, pdi = pd ∧ pdi.status = pd.status)

example : Spec.pre { payloadData := [{ status := "active" }, { status := "inactive" }] } ∧
          Spec.post { payloadData := [{ status := "active" }, { status := "inactive" }] }
                    { presented := [{ status := "active" }, { status := "inactive" }], statusDetermined := true } := by
  unfold Spec; decide
