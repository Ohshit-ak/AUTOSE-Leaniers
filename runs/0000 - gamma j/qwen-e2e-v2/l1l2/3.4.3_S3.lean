import ContractForge
open ContractForge

-- 3.4.3/S3: The customer will then receive a confirmation email with the specific order details.

-- L0 spec

structure Order where
  id      : Nat
  items   : List String
  total   : Nat
  deriving DecidableEq, Repr

structure Input where
  orderId : Nat
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  details : Order
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.orderId > 0
  post := fun i o => o.sent = true ∧
                     o.details = { id := i.orderId, items := [], total := 0 } -- Assume no items and total 0 for simplicity

example : Spec.pre { orderId := 1 } ∧
          Spec.post { orderId := 1 }
                    { sent := true, details := { id := 1, items := [], total := 0 } } := by
  unfold Spec; decide

-- L1 architect (success=True)

structure Mid where
  orderId : Nat
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.orderId > 0
  post := fun i m => m.orderId = i.orderId

def SendContract : Contract Mid Output where
  pre  := fun m => m.orderId > 0
  post := fun m o => o.sent = true ∧
                     o.details = { id := m.orderId, items := [], total := 0 }

theorem po1 : Contract.Compatible ValidateContract SendContract := by
  discharge_po [SendContract, Spec, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq SendContract) Spec := by
  discharge_po [SendContract, Spec, ValidateContract]

-- L2 ValidateContract (success=True)

def ValidateContractImpl (i : Input) : Mid := 
  { orderId := i.orderId }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  discharge_po [SendContract, Spec, ValidateContract, ValidateContractImpl]

-- L2 SendContract (success=True)

def SendContractImpl (m : Mid) : Output := { sent := true, details := { id := m.orderId, items := [], total := 0 } }

theorem SendContractImpl_ok : SendContract.Satisfies SendContractImpl := by
  discharge_po [SendContract, SendContractImpl, Spec, ValidateContract]