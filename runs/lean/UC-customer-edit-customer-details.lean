-- UC-customer-edit-customer-details: Edit Customer Details: Edit the customer account details.
-- checked: None

structure CustomerDetails where
  name : String
  email : String
  phone : String

structure SystemState where
  customers : List (String × CustomerDetails)

structure Input where
  loggedCustomer : String
  newDetails : CustomerDetails

structure Output where
  updatedCustomers : SystemState

def Spec : Contract Input Output where
  pre c s := 
    List.mem c.loggedCustomer (List.map (·.1) s.customers) ∧
    CustomerDetails.neq c.newDetails (List.find (·.1 = c.loggedCustomer) s.customers).2
  post c s s' := 
    List.find (·.1 = c.loggedCustomer) s'.customers.2 = c.newDetails

example : Spec (Input.mk "user123" { name := "John Doe", email := "johndoe@example.com", phone := "1234567890" }) (Output.mk { customers := [("user123", { name := "John Doe", email := "johndoe@example.com", phone := "1234567890" })] } ) := 
  by
    simp [Spec.pre, Spec.post]
    split
    · simp
    · simp
