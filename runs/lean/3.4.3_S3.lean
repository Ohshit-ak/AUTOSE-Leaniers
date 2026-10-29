-- 3.4.3/S3: The customer will then receive a confirmation email with the specific order details.
-- checked: None

structure OrderDetails where
  items : List String
  total : Nat

structure EmailContent where
  subject : String
  body : String

structure Input where
  orderDetails : OrderDetails

structure Output where
  emailContent : EmailContent

def Spec : Contract Input Output where
  pre := fun i => true
  post := fun i o => 
    o.emailContent.subject = "Order Confirmation" ∧
    o.emailContent.body = "Your order includes: " ++ i.orderDetails.items.join(", ") ++ ". Total: $" ++ (toString i.orderDetails.total)

example : Spec := 
{ pre := fun _ => true,
  post := fun i o =>
    o.emailContent.subject = "Order Confirmation" ∧
    o.emailContent.body = "Your order includes: " ++ i.orderDetails.items.join(", ") ++ ". Total: $" ++ (toString i.orderDetails.total) }
