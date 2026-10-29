-- UC-customer-register-customer: Register Customer: Register a new customer account with the system.
-- checked: None

structure Customer where
  name : String
  email : String
  password : String

structure Input where
  customer : Customer
  cookie : Option String

structure Output where
  accountCreated : Bool
  sessionCookie : String

def Spec : Contract Input Output where
  pre input := 
    input.customer.name ≠ "" ∧
    input.customer.email ≠ "" ∧
    input.customer.password ≠ "" ∧
    input.cookie = none
  post input output := 
    output.accountCreated ∧
    output.sessionCookie ≠ ""

example : Spec
where
  input := 
    { customer := Customer { name := "John Doe", email := "johndoe@example.com", password := "password123" }, cookie := none }
  output := 
    { accountCreated := true, sessionCookie := "session12345" }
