-- 3.1.3/S3: Furthermore, Customer profiles will also include payment information, such as the ability to store credit card information, and address information.
-- checked: None

structure CustomerProfile where
  name : String
  paymentInfo : Option (String × String) -- (cardType, cardNumber)
  addressInfo : Option (String × String × String) -- (street, city, zipCode)

structure Input where
  profiles : List CustomerProfile

structure Output where
  updatedProfiles : List CustomerProfile

def Spec : Contract Input Output where
  pre input := true
  post input output := 
    input.profiles = output.updatedProfiles ∧
    input.profiles.Perm output.updatedProfiles

example : Spec
input := {
  profiles := [
    { name := "Alice"; paymentInfo := some ("Visa", "1234567890123456"); addressInfo := some ("123 Main St", "Anytown", "12345") },
    { name := "Bob"; paymentInfo := none; addressInfo := none }
  ]
}
output := {
  updatedProfiles := [
    { name := "Alice"; paymentInfo := some ("Visa", "1234567890123456"); addressInfo := some ("123 Main St", "Anytown", "12345") },
    { name := "Bob"; paymentInfo := none; addressInfo := none }
  ]
}
