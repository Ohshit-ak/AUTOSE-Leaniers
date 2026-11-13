import ContractForge
open ContractForge

-- 2.5/S1: SYSTEM INTEGRATION AND DATA EXCHANGE Systems integration requirements specific to systems supporting OM are included in the section below and describe the types of data that OM should be able to send and receive.

-- L0 spec

structure Input where
  outbreakData : String
  deriving DecidableEq, Repr

structure Output where
  receivedData : String
  status       : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.outbreakData ≠ ""
  post := fun i o => (o.status = "Data received successfully" ↔
    o.receivedData = i.outbreakData) ∧
    (o.status = "Data not received" → o.receivedData = "")

example : Spec.pre { outbreakData := "Outbreak details" } ∧
          Spec.post { outbreakData := "Outbreak details" }
                    { receivedData := "Outbreak details", status := "Data received successfully" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  receivedData : String
  deriving DecidableEq, Repr

def ReceiveDataContract : Contract Input Mid where
  pre  := fun i => i.outbreakData ≠ ""
  post := fun i m => m.receivedData = i.outbreakData

def UpdateStatusContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.status = "Data received successfully" ↔ o.receivedData = m.receivedData) ∧
                     (o.status = "Data not received" → o.receivedData = "")
