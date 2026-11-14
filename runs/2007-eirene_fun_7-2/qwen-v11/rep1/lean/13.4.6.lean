import ContractForge
open ContractForge

-- 13.4.6: 13.4.6 For Railway emergency calls received by a mobile, the automatic confirmation message of the receiving mobile shall contain: (M) the time at which the call was first received; the time at which the call was lost (or terminated); the group identity of the sender; the functional number of the recipient; the train number and engine number of the recipient, if a train.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  callTimeReceived : Nat  -- time at which the call was first received
  callTimeLost     : Nat  -- time at which the call was lost (or terminated)
  senderGroupID    : String
  recipientFuncNum : String
  recipientTrainNum : Option String
  recipientEngineNum : Option String
  deriving DecidableEq, Repr

structure Output where
  confirmationMessage : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => 
    o.confirmationMessage = 
      s!"Time received: {i.callTimeReceived} µs, Time lost: {i.callTimeLost} µs, " ++
      s!"Sender group ID: {i.senderGroupID}, Recipient functional number: {i.recipientFuncNum}, " ++
      s!"Recipient train number: {i.recipientTrainNum.getD ""}, " ++
      s!"Recipient engine number: {i.recipientEngineNum.getD ""}"

example : Spec.pre { callTimeReceived := 1000, callTimeLost := 2000, 
                     senderGroupID := "GRP123", recipientFuncNum := "FN456", 
                     recipientTrainNum := some "T789", recipientEngineNum := some "E012" } ∧
          Spec.post { callTimeReceived := 1000, callTimeLost := 2000, 
                      senderGroupID := "GRP123", recipientFuncNum := "FN456", 
                      recipientTrainNum := some "T789", recipientEngineNum := some "E012" }
                    { confirmationMessage := "Time received: 1000 µs, Time lost: 2000 µs, Sender group ID: GRP123, Recipient functional number: FN456, Recipient train number: T789, Recipient engine number: E012" } := by
  set_option maxRecDepth 1000 in
  unfold Spec; decide
