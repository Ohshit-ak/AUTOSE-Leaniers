import ContractForge
open ContractForge

-- 5.5.2/S1: The sequence of actions for a mobile terminated call to a driver shall be as follows: (M)

-- L0 spec

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

-- L1 architecture (mode=chain, success=True)

structure Mid where
  calls : List Call
  newCall : Call
  deriving DecidableEq, Repr

def ComputeNewCallContract : Contract Input Mid where
  pre  := fun i => i.calls.length < 100
  post := fun i m => m.calls = i.calls ++ [m.newCall] ∧
                     m.newCall.callerId ≠ "" ∧
                     m.newCall.recipientId ≠ ""

def UpdateCallsContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.calls = m.calls ∧
                     o.newCall = m.newCall ∧
                     o.newCall.status = "initiated"

theorem po1 : Contract.Compatible ComputeNewCallContract UpdateCallsContract := by
  discharge_po1 [ComputeNewCallContract, UpdateCallsContract, Spec]

theorem po2 : Contract.Refines (ComputeNewCallContract.seq UpdateCallsContract) Spec := by
  discharge_po2 [ComputeNewCallContract, UpdateCallsContract, Spec]

-- L2 ComputeNewCallContract (success=False)

def ComputeNewCallContractImpl (x : Input) : Mid :=
  { calls := x.calls ++ [x.newCall], newCall := x.newCall }

-- L2 UpdateCallsContract (success=False)

def UpdateCallsContractImpl (x : Mid) : Output :=
  { calls := x.calls,
    newCall := { callerId := x.newCall.callerId, recipientId := x.newCall.recipientId, status := "initiated" } }
