import ContractForge
open ContractForge

-- 12.2.1: 12.2.1 It should be possible to transfer text messages between ground and mobile(s) through the EIRENE system. (O)

-- L0 spec

structure Input where
  groundMessage : String
  mobileNumbers : List String
  deriving DecidableEq, Repr

structure Output where
  sentMessages : List String
  failedNumbers : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.groundMessage ≠ "" ∧ i.mobileNumbers.Nodup
  post := fun i o => (o.sentMessages.length = i.mobileNumbers.length - o.failedNumbers.length) ∧
                     (∀ n ∈ i.mobileNumbers, o.sentMessages.contains n ↔
                      (n = i.groundMessage || o.failedNumbers.contains n))

example : Spec.pre { groundMessage := "Hello", mobileNumbers := [] } ∧ Spec.post { groundMessage := "Hello", mobileNumbers := [] } { sentMessages := [], failedNumbers := ["789"] } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  sentMessages : List String
  failedNumbers : List String
  deriving DecidableEq, Repr

def SendMessagesContract : Contract Input Mid where
  pre  := fun i => i.groundMessage ≠ "" ∧ i.mobileNumbers.Nodup
  post := fun i m => m.sentMessages.length = i.mobileNumbers.length - m.failedNumbers.length ∧
                     (∀ n ∈ i.mobileNumbers, m.sentMessages.contains n ↔
                      (n = i.groundMessage || m.failedNumbers.contains n))

def ProcessResultsContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.sentMessages = m.sentMessages ∧
                     o.failedNumbers = m.failedNumbers ∧
                     (o.sentMessages.length = m.sentMessages.length - o.failedNumbers.length)

theorem po1 : Contract.Compatible SendMessagesContract ProcessResultsContract := by
  discharge_po1 [SendMessagesContract, ProcessResultsContract, Spec]

theorem po2 : Contract.Refines (SendMessagesContract.seq ProcessResultsContract) Spec := by
  discharge_po2 [SendMessagesContract, ProcessResultsContract, Spec]

-- L2 SendMessagesContract (success=False)

def SendMessagesContractImpl (x : Input) : Mid :=
  { sentMessages := x.mobileNumbers, failedNumbers := [] }

-- L2 ProcessResultsContract (success=False)

def ProcessResultsContractImpl (x : Mid) : Output :=
  { sentMessages := x.sentMessages,
    failedNumbers := x.failedNumbers }
