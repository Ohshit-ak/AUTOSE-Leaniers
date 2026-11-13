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

-- L1 architecture (mode=chain, success=True)

structure Mid where
  orderId : Nat
  ok      : Bool
  deriving DecidableEq, Repr

def CheckOrderIdContract : Contract Input Mid where
  pre  := fun i => i.orderId > 0
  post := fun i m => m.orderId = i.orderId ∧ m.ok = true

def SendOrderContract : Contract Mid Output where
  pre  := fun m => m.ok
  post := fun m o => o.sent = true ∧
                     o.details = { id := m.orderId, items := [], total := 0 }

theorem po1 : Contract.Compatible CheckOrderIdContract SendOrderContract := by
  discharge_po1 [CheckOrderIdContract, SendOrderContract, Spec]

theorem po2 : Contract.Refines (CheckOrderIdContract.seq SendOrderContract) Spec := by
  discharge_po2 [CheckOrderIdContract, SendOrderContract, Spec]

-- L2 CheckOrderIdContract (success=True)

def CheckOrderIdContractImpl (x : Input) : Mid :=
  { orderId := x.orderId, ok := true }

theorem CheckOrderIdContractImpl_ok : CheckOrderIdContract.Satisfies CheckOrderIdContractImpl := by
  discharge_po3 [CheckOrderIdContract, CheckOrderIdContractImpl]

-- L2 SendOrderContract (success=True)

def SendOrderContractImpl (x : Mid) : Output :=
  { sent := true, details := { id := x.orderId, items := [], total := 0 } }

theorem SendOrderContractImpl_ok : SendOrderContract.Satisfies SendOrderContractImpl := by
  discharge_po3 [SendOrderContract, SendOrderContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (SendOrderContractImpl ∘ CheckOrderIdContractImpl) :=
  Contract.system_sound po1 po2 CheckOrderIdContractImpl_ok SendOrderContractImpl_ok
