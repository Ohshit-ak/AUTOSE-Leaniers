-- 5.5/R2: For returning customers, the system shall validate 'existing' credit card in system after each log in.
-- checked: None

structure Contract (Input Output) where
  pre  : Input → Prop
  post : Input → Output → Prop

structure CustomerData where
  creditCardNumber : String

structure LoginData where
  customerData : CustomerData
  creditCardNumber : String

def Spec : Contract LoginData CustomerData where
  pre loginData := true
  post loginData customerData' := 
    customerData'.creditCardNumber = loginData.creditCardNumber ∧
    CustomerData.Perm (List.cons loginData.customerData (List.nil : List CustomerData))

example : Spec (LoginData.mk (CustomerData.mk "1234567890123456") "1234567890123456") (CustomerData.mk "1234567890123456") := 
  begin
    simp,
    exact true
  end
