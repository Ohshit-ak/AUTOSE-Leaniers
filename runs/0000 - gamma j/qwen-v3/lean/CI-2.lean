-- CI-2: The WebOrder system shall send an e-mail to System Administrator regarding any technical queries from customers or sales people.
-- checked: True

structure Input where
  queryType : String
  content   : String
  deriving DecidableEq, Repr

structure Output where
  sentToAdmin : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.sentToAdmin = true ∧
                     (i.queryType = "technical" ∧ i.content.length > 0)

example : Spec.pre { queryType := "technical", content := "Query details" } ∧
          Spec.post { queryType := "technical", content := "Query details" }
                     { sentToAdmin := true } := by
  unfold Spec; decide
