import ContractForge
open ContractForge

-- 5.5.2/S1: The sequence of actions for a mobile terminated call to a driver shall be as follows: (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Call where
  callerId : String
  recipientId : String
  status : String
  deriving DecidableEq, Repr

structure Input where
  calls : List Call
  newCall : Call
  deriving DecidableEq, Repr

structure Output where
  calls : List Call
  newCall : Call
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.calls.length < 100
  post := fun i o =>
    o.calls = i.calls ++ [o.newCall] ∧
    o.newCall.callerId ≠ "" ∧
    o.newCall.recipientId ≠ "" ∧
    o.newCall.status = "initiated"

example : Spec.pre { calls := [{ callerId := "A123", recipientId := "B456", status := "completed" }],
                     newCall := { callerId := "X789", recipientId := "Y012", status := "initiated" } }
          ∧ Spec.post { calls := [{ callerId := "A123", recipientId := "B456", status := "completed" }],
                        newCall := { callerId := "X789", recipientId := "Y012", status := "initiated" } }
                    { calls := [{ callerId := "A123", recipientId := "B456", status := "completed" },
                                { callerId := "X789", recipientId := "Y012", status := "initiated" }], newCall := { callerId := "X789", recipientId := "Y012", status := "initiated" } } := by
  unfold Spec; decide
