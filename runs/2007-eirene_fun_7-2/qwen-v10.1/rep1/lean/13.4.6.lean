import ContractForge
open ContractForge

-- 13.4.6: 13.4.6 For Railway emergency calls received by a mobile, the automatic confirmation message of the receiving mobile shall contain: (M) the time at which the call was first received; the time at which the call was lost (or terminated); the group identity of the sender; the functional number of the recipient; the train number and engine number of the recipient, if a train.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  callTimeReceived : Nat  -- time at which the call was first received
  callTimeLost     : Nat  -- time at which the call was lost (or terminated)
  senderGroup      : String
  recipientFuncNum : String
  recipientTrain   : Option String
  recipientEngine  : Option String
  deriving DecidableEq, Repr

structure Output where
  confirmationMessage : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => 
    o.confirmationMessage = 
      s!"Time received: {i.callTimeReceived}, Time lost: {i.callTimeLost}, Sender group: {i.senderGroup}, Recipient functional number: {i.recipientFuncNum}, Recipient train: {i.recipientTrain.getD ""}, Recipient engine: {i.recipientEngine.getD ""}"

example : Spec.pre { callTimeReceived := 1452, callTimeLost := 1500, senderGroup := "GRP123", recipientFuncNum := "FN456", recipientTrain := some "T123", recipientEngine := some "E456" } ∧
          Spec.post { callTimeReceived := 1452, callTimeLost := 1500, senderGroup := "GRP123", recipientFuncNum := "FN456", recipientTrain := some "T123", recipientEngine := some "E456" }
                    { confirmationMessage := "Time received: 1452, Time lost: 1500, Sender group: GRP123, Recipient functional number: FN456, Recipient train: T123, Recipient engine: E456" } := by
  set_option maxRecDepth 1000 in
  unfold Spec; decide
