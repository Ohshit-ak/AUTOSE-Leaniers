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
  sent    : Bool
  deriving DecidableEq, Repr

def SendOrderContract : Contract Input Mid where
  pre  := fun i => i.orderId > 0
  post := fun i m => m.orderId = i.orderId ∧ m.sent = true

def PrepareDetailsContract : Contract Mid Output where
  pre  := fun m => m.sent = true
  post := fun m o => o.sent = true ∧
                     o.details = { id := m.orderId, items := [], total := 0 }

theorem po1 : Contract.Compatible SendOrderContract PrepareDetailsContract := by
  discharge_po1 [SendOrderContract, PrepareDetailsContract, Spec]

theorem po2 : Contract.Refines (SendOrderContract.seq PrepareDetailsContract) Spec := by
  discharge_po2 [SendOrderContract, PrepareDetailsContract, Spec]

-- L2 SendOrderContract (success=True)

def SendOrderContractImpl (x : Input) : Mid :=
  { orderId := x.orderId, sent := true }

theorem SendOrderContractImpl_ok : SendOrderContract.Satisfies SendOrderContractImpl := by
  discharge_po3 [SendOrderContract, SendOrderContractImpl]

-- L2 PrepareDetailsContract (success=True)

def PrepareDetailsContractImpl (x : Mid) : Output :=
  { sent := true, details := { id := x.orderId, items := [], total := 0 } }

theorem PrepareDetailsContractImpl_ok : PrepareDetailsContract.Satisfies PrepareDetailsContractImpl := by
  discharge_po3 [PrepareDetailsContract, PrepareDetailsContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (PrepareDetailsContractImpl ∘ SendOrderContractImpl) :=
  Contract.system_sound po1 po2 SendOrderContractImpl_ok PrepareDetailsContractImpl_ok
