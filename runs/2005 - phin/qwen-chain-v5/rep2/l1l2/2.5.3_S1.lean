import ContractForge
open ContractForge

-- 2.5.3/S1: Systems supporting OM must be able to create and send messages for laboratory test requests.

-- L0 spec

structure TestRequest where
  patientID : Nat
  testCode  : String
  results   : Option String
  deriving DecidableEq, Repr

structure Input where
  patientID : Nat
  testCode  : String
  results   : Option String
  send      : Bool
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  messageID : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.patientID ≠ 0 ∧ i.testCode ≠ "" ∧ i.send
  post := fun i o => (o.sent = true ↔ i.results.isSome) ∧
                     (o.sent = false ↔ i.results.isNone) ∧
                     (o.sent = true → o.messageID ≠ 0)

example : Spec.pre { patientID := 123, testCode := "TEST123", results := some "Positive", send := true } ∧
          Spec.post { patientID := 123, testCode := "TEST123", results := some "Positive", send := true }
                    { sent := true, messageID := 456 } := by
  unfold Spec; decide

example : Spec.pre { patientID := 123, testCode := "TEST123", results := none, send := true } ∧
          Spec.post { patientID := 123, testCode := "TEST123", results := none, send := true }
                    { sent := false, messageID := 0 } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  messageID : Nat
  deriving DecidableEq, Repr

def ComputeMessageIDContract : Contract Input Mid where
  pre  := fun i => i.patientID ≠ 0 ∧ i.testCode ≠ "" ∧ i.send
  post := fun i m => m.messageID ≠ 0 ∧
                     (m.messageID = 0 ↔ i.results.isNone) ∧
                     (m.messageID ≠ 0 ↔ i.results.isSome)

def SendResultsContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.sent = true ↔ m.messageID ≠ 0) ∧
                     (o.sent = false ↔ m.messageID = 0) ∧
                     (o.sent = true → o.messageID ≠ 0)

theorem po1 : Contract.Compatible ComputeMessageIDContract SendResultsContract := by
  discharge_po1 [ComputeMessageIDContract, SendResultsContract, Spec]

theorem po2 : Contract.Refines (ComputeMessageIDContract.seq SendResultsContract) Spec := by
  discharge_po2 [ComputeMessageIDContract, SendResultsContract, Spec]

-- L2 ComputeMessageIDContract (success=False)

def ComputeMessageIDContractImpl (x : Input) : Mid :=
  { messageID := if x.results.isNone then 0 else 1 }

-- L2 SendResultsContract (success=True)

def SendResultsContractImpl (x : Mid) : Output :=
  { sent := decide (x.messageID ≠ 0),
    messageID := if x.messageID = 0 then 0 else x.messageID }

theorem SendResultsContractImpl_ok : SendResultsContract.Satisfies SendResultsContractImpl := by
  discharge_po3 [SendResultsContract, SendResultsContractImpl]
