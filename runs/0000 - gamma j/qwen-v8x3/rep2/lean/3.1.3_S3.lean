import ContractForge
open ContractForge

-- 3.1.3/S3: Furthermore, Customer profiles will also include payment information, such as the ability to store credit card information, and address information.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  creditCardNumber : String
  addressLine1    : String
  addressLine2    : String
  city            : String
  state           : String
  zipCode         : String
  deriving DecidableEq, Repr

structure Output where
  profileUpdated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.creditCardNumber ≠ "" ∧
                   i.addressLine1 ≠ "" ∧
                   i.addressLine2 ≠ "" ∧
                   i.city ≠ "" ∧
                   i.state ≠ "" ∧
                   i.zipCode ≠ ""
  post := fun i o => o.profileUpdated = true ↔
    (i.creditCardNumber ≠ i.creditCardNumber ∨
     i.addressLine1 ≠ i.addressLine1 ∨
     i.addressLine2 ≠ i.addressLine2 ∨
     i.city ≠ i.city ∨
     i.state ≠ i.state ∨
     i.zipCode ≠ i.zipCode)

example : Spec.pre { creditCardNumber := "1234567890123456", addressLine1 := "123 Main St", addressLine2 := "Apt 4B", city := "Anytown", state := "CA", zipCode := "90210" } ∧
          Spec.post { creditCardNumber := "1234567890123456", addressLine1 := "123 Main St", addressLine2 := "Apt 4B", city := "Anytown", state := "CA", zipCode := "90210" }
                    { profileUpdated := false } := by
  unfold Spec; decide
