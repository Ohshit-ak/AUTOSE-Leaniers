-- UC-customer-checkout-an-order: Checkout An Order: Customer places and confirms an order for the checkout process.
-- checked: False

structure Input where
  customerLogged : Bool
  shoppingCartNotEmpty : Bool
  orderCalculated : Bool
  checkoutCookieFlag : Bool
  accountDetailsConfirmed : Bool
  paymentMethodsConfirmed : Bool
  orderConfirmed : Bool
  orderStored : Bool
  emailConfirmationSent : Bool
  checkoutCompleted : Bool

structure Output where
  orderPlaced : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.customerLogged ∧ i.shoppingCartNotEmpty
  post := fun i o => o.orderPlaced = true ∧ i.orderCalculated ∧ i.accountDetailsConfirmed ∧ i.paymentMethodsConfirmed ∧ i.orderConfirmed ∧ i.orderStored ∧ i.emailConfirmationSent ∧ i.checkoutCompleted

example : Spec.pre ⟨true, true, false, false, false, false, false, false, false, false⟩ ∧ Spec.post ⟨true, ⟨true⟩⟩ := by
  simp [Spec]
