-- 3.1.3/S3: Furthermore, Customer profiles will also include payment information, such as the ability to store credit card information, and address information.
-- checked: True

structure Input where
  creditCardNumber : Option String
  addressLine1    : Option String
  addressLine2    : Option String
  city            : Option String
  state           : Option String
  zipCode         : Option String
  deriving DecidableEq, Repr

structure Output where
  creditCardNumber : Option String
  addressLine1    : Option String
  addressLine2    : Option String
  city            : Option String
  state           : Option String
  zipCode         : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => i.creditCardNumber = o.creditCardNumber ∧
                     i.addressLine1 = o.addressLine1 ∧
                     i.addressLine2 = o.addressLine2 ∧
                     i.city = o.city ∧
                     i.state = o.state ∧
                     i.zipCode = o.zipCode

example : Spec.pre { creditCardNumber := none, addressLine1 := none, addressLine2 := none, city := none, state := none, zipCode := none } ∧
          Spec.post { creditCardNumber := none, addressLine1 := none, addressLine2 := none, city := none, state := none, zipCode := none }
                    { creditCardNumber := none, addressLine1 := none, addressLine2 := none, city := none, state := none, zipCode := none } := by
  unfold Spec; decide
