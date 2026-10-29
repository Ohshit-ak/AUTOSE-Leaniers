-- CI-1: The WebOrder system shall send an e-mail confirmation to the customer that the items they ordered will be delivered to the shipping address along with tracking number.
-- checked: None

structure Contract (Input Output : Type) where
  pre  : Input → Prop
  post : Input → Output → Prop

def Spec : Contract (List String) (String × List String) where
  pre input := 
    input.length = 3 ∧
    input[0] = "customerEmail" ∧
    input[1] = "orderItems" ∧
    input[2] = "shippingAddress"
  
  post input output := 
    output.1 = "Email confirmation sent" ∧
    output.2.length = 2 ∧
    output.2[0] = "deliveryAddress" ∧
    output.2[1] = "trackingNumber"

example : Spec [ "customerEmail", "orderItems", "shippingAddress" ] ( "Email confirmation sent", [ "deliveryAddress", "trackingNumber" ] ) :=
  by
    simp [Spec]
    exact And.intro
      (by
        simp
        exact And.intro
          (by
            simp
            exact Eq.refl "Email confirmation sent")
          (by
            simp
            exact Eq.refl [ "deliveryAddress", "trackingNumber" ]))
      (by
        simp
        exact And.intro
          (by
            simp
            exact Eq.refl "Email confirmation sent")
          (by
            simp
            exact And.intro
              (by
                simp
                exact Eq.refl "deliveryAddress")
              (by
                simp
                exact Eq.refl "trackingNumber")))
