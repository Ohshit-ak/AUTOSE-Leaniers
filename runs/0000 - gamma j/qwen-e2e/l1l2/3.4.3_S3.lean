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

-- L1 architect (success=False)

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
                     o.details = { id := i.orderId, items := [], total := 0 }

-- Component 1: Check if the order ID is valid
def CheckOrderIdContract : Contract Input Input where
  pre  := fun i => i.orderId > 0
  post := fun i i' => i' = i

-- Component 2: Send the order details
def SendOrderDetailsContract : Contract Input Output where
  pre  := fun i => i.orderId > 0
  post := fun i o => o.sent = true ∧
                     o.details = { id := i.orderId, items := [], total := 0 }

-- Prove PO1: CheckOrderIdContract's postcondition is compatible with Spec's precondition
example : Contract.Compatible (CheckOrderIdContract.post) Spec.pre := by
  intros i i' hi
  simp [CheckOrderIdContract.post, Spec.pre]
  exact hi

-- Prove PO2: CheckOrderIdContract and SendOrderDetailsContract together refine Spec
example : Contract.Refines (CheckOrderIdContract.seq SendOrderDetailsContract) Spec := by
  unfold CheckOrderIdContract SendOrderDetailsContract Spec
  simp [Contract.seq, Contract.Refines]
  discharge_po