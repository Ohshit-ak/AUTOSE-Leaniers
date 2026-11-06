import ContractForge
open ContractForge

-- CI-1: The WebOrder system shall send an e-mail confirmation to the customer that the items they ordered will be delivered to the shipping address along with tracking number.

-- L0 spec

structure Input where
  customerEmail : String
  items         : List String
  shippingAddr  : String
  trackingNum   : String
  deriving DecidableEq, Repr

structure Output where
  sentEmail : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.customerEmail ≠ "" ∧ i.items.Nodup ∧ i.shippingAddr ≠ "" ∧ i.trackingNum ≠ ""
  post := fun i o => o.sentEmail = true ↔
    (i.customerEmail ≠ "" ∧ i.items.Nodup ∧ i.shippingAddr ≠ "" ∧ i.trackingNum ≠ "")

example : Spec.pre { customerEmail := "customer@example.com", items := ["item1", "item2"], shippingAddr := "123 Main St", trackingNum := "1234567890" } ∧
          Spec.post { customerEmail := "customer@example.com", items := ["item1", "item2"], shippingAddr := "123 Main St", trackingNum := "1234567890" }
                    { sentEmail := true } := by
  unfold Spec; decide

-- L1 architect (success=True)

structure Mid where
  customerEmail : String
  items         : List String
  shippingAddr  : String
  trackingNum   : String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.customerEmail ≠ "" ∧ i.items.Nodup ∧ i.shippingAddr ≠ "" ∧ i.trackingNum ≠ ""
  post := fun i m => m.customerEmail = i.customerEmail ∧ m.items = i.items ∧ m.shippingAddr = i.shippingAddr ∧ m.trackingNum = i.trackingNum

def SendEmailContract : Contract Mid Output where
  pre  := fun m => m.customerEmail ≠ "" ∧ m.items.Nodup ∧ m.shippingAddr ≠ "" ∧ m.trackingNum ≠ ""
  post := fun m o => o.sentEmail = true

theorem po1 : Contract.Compatible ValidateContract SendEmailContract := by
  discharge_po [SendEmailContract, Spec, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq SendEmailContract) Spec := by
  discharge_po [SendEmailContract, Spec, ValidateContract]

-- L2 ValidateContract (success=True)

def ValidateContractImpl (i : Input) : Mid := 
  { customerEmail := i.customerEmail, 
    items         := i.items, 
    shippingAddr  := i.shippingAddr, 
    trackingNum   := i.trackingNum }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  discharge_po [SendEmailContract, Spec, ValidateContract, ValidateContractImpl]

-- L2 SendEmailContract (success=True)

def SendEmailContractImpl (m : Mid) : Output := { sentEmail := true }

theorem SendEmailContractImpl_ok : SendEmailContract.Satisfies SendEmailContractImpl := by
  discharge_po [SendEmailContract, SendEmailContractImpl, Spec, ValidateContract]