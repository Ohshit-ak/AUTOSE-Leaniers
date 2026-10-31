import ContractForge
open ContractForge

-- 3.1.3/S3: Furthermore, Customer profiles will also include payment information, such as the ability to store credit card information, and address information.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  profile_updated : Bool
  credit_card_number : String
  address_line1      : String
  address_line2      : Option String
  address_city       : String
  address_state      : String
  address_zip        : String
  deriving DecidableEq, Repr

structure Output where
  profile_updated : Bool
  credit_card_number : String
  address_line1      : String
  address_line2      : Option String
  address_city       : String
  address_state      : String
  address_zip        : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.credit_card_number ≠ "" ∧
                   i.address_line1 ≠ "" ∧
                   i.address_city ≠ "" ∧
                   i.address_state ≠ "" ∧
                   i.address_zip ≠ ""
  post := fun i o => o.profile_updated = true ∧
                     (o.credit_card_number = i.credit_card_number ∧
                      o.address_line1 = i.address_line1 ∧
                      o.address_line2 = i.address_line2 ∧
                      o.address_city = i.address_city ∧
                      o.address_state = i.address_state ∧
                      o.address_zip = i.address_zip)

example : Spec.pre { profile_updated := true,
                     credit_card_number := "1234567812345678",
                     address_line1 := "123 Main St",
                     address_line2 := none,
                     address_city := "Anytown",
                     address_state := "CA",
                     address_zip := "12345" } ∧
          Spec.post { profile_updated := true,
                      credit_card_number := "1234567812345678",
                      address_line1 := "123 Main St",
                      address_line2 := none,
                      address_city := "Anytown",
                      address_state := "CA",
                      address_zip := "12345",
                      profile_updated := true } 
                    { profile_updated := true } := by
  unfold Spec; decide
