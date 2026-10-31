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
  pre  := fun _ => true
  post := fun i o => i.creditCardNumber = o.creditCardNumber ∧
                     i.addressLine1 = o.addressLine1 ∧
                     i.addressLine2 = o.addressLine2 ∧
                     i.city = o.city ∧
                     i.state = o.state ∧
                     i.zipCode = o.zipCode

example : Spec.pre { creditCardNumber := "1234567890123456", addressLine1 := "123 Elm St", addressLine2 := "Apt 4B", city := "Springfield", state := "IL", zipCode := "62704" } ∧
          Spec.post { creditCardNumber := "1234567890123456", addressLine1 := "123 Elm St", addressLine2 := "Apt 4B", city := "Springfield", state := "IL", zipCode := "62704" }
                    { creditCardNumber := "1234567890123456", addressLine1 := "123 Elm St", addressLine2 := "Apt 4B", city := "Springfield", state := "IL", zipCode := "62704" } := by
  unfold Spec; decide
