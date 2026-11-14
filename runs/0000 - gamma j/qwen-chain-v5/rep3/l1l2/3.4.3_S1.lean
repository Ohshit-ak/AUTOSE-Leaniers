import ContractForge
open ContractForge

-- 3.4.3/S1: Customers will be able to confirm the order after checkout.

-- L0 spec

structure Cart where
  items : List String
  deriving DecidableEq, Repr

structure Customer where
  name : String
  address : String
  deriving DecidableEq, Repr

structure Input where
  cart : Cart
  customer : Customer
  confirming : Bool
  deriving DecidableEq, Repr

structure Output where
  confirmed : Bool
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.confirming = true
  post := fun i o => (o.confirmed = true ↔ i.cart.items.Nodup) ∧
                     (o.confirmed = false → o.message = "Order cannot be confirmed: items are not unique")

example : Spec.pre { cart := { items := ["apple", "banana", "apple"] }, customer := { name := "John Doe", address := "123 Main St" }, confirming := true } ∧
          Spec.post { cart := { items := ["apple", "banana", "apple"] }, customer := { name := "John Doe", address := "123 Main St" }, confirming := true }
                    { confirmed := false, message := "Order cannot be confirmed: items are not unique" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  itemsNodup : Bool
  deriving DecidableEq, Repr

def CheckItemsContract : Contract Input Mid where
  pre  := fun i => i.confirming = true
  post := fun i m => m.itemsNodup = (i.cart.items).Nodup

def ConfirmOrderContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.confirmed = true ↔ m.itemsNodup) ∧
                     (o.confirmed = false → o.message = "Order cannot be confirmed: items are not unique")

theorem po1 : Contract.Compatible CheckItemsContract ConfirmOrderContract := by
  discharge_po1 [CheckItemsContract, ConfirmOrderContract, Spec]

theorem po2 : Contract.Refines (CheckItemsContract.seq ConfirmOrderContract) Spec := by
  discharge_po2 [CheckItemsContract, ConfirmOrderContract, Spec]

-- L2 CheckItemsContract (success=True)

def CheckItemsContractImpl (x : Input) : Mid :=
  { itemsNodup := (x.cart.items).Nodup }

theorem CheckItemsContractImpl_ok : CheckItemsContract.Satisfies CheckItemsContractImpl := by
  discharge_po3 [CheckItemsContract, CheckItemsContractImpl]

-- L2 ConfirmOrderContract (success=True)

def ConfirmOrderContractImpl (x : Mid) : Output :=
  { confirmed := decide (x.itemsNodup),
    message := if x.itemsNodup then "Order confirmed" else "Order cannot be confirmed: items are not unique" }

theorem ConfirmOrderContractImpl_ok : ConfirmOrderContract.Satisfies ConfirmOrderContractImpl := by
  discharge_po3 [ConfirmOrderContract, ConfirmOrderContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (ConfirmOrderContractImpl ∘ CheckItemsContractImpl) :=
  Contract.system_sound po1 po2 CheckItemsContractImpl_ok ConfirmOrderContractImpl_ok
