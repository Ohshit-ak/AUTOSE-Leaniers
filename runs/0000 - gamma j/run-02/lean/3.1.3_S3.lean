-- 3.1.3/S3: Furthermore, Customer profiles will also include payment information, such as the ability to store credit card information, and address information.
-- checked: False

structure Input where
  creditCardNumber : String
  addressLine1    : String
  addressLine2    : String
  city            : String
  state           : String
  zipCode         : String
  deriving DecidableEq, Repr

structure Output where
  success         : Bool
  message         : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 
    i.creditCardNumber.length = 16 ∧
    i.addressLine1.length ≤ 100 ∧
    i.addressLine2.length ≤ 100 ∧
    i.city.length ≤ 100 ∧
    i.state.length ≤ 100 ∧
    i.zipCode.length = 5
  post := fun i o => o.success = true ↔
    (i.creditCardNumber.length = 16 ∧
     i.addressLine1.length ≤ 100 ∧
     i.addressLine2.length ≤ 100 ∧
     i.city.length ≤ 100 ∧
     i.state.length ≤ 100 ∧
     i.zipCode.length = 5) ∧
    o.message = "Profile updated successfully"

example : Spec.pre { creditCardNumber := "1234567890123456", addressLine1 := "123 Elm St", 
                     addressLine2 := "Apt 4B", city := "Springfield", state := "Illinois", 
                     zipCode := "62704" } ∧
          Spec.post { creditCardNumber := "1234567890123456", addressLine1 := "123 Elm St", 
                      addressLine2 := "Apt 4B", city := "Springfield", state := "Illinois", 
                      zipCode := "62704" }
                    { success := true, message := "Profile updated successfully" } := by
  unfold Spec; decide
