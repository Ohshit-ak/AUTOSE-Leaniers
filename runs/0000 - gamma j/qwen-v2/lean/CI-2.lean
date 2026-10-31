-- CI-2: The WebOrder system shall send an e-mail to System Administrator regarding any technical queries from customers or sales people.
-- checked: True

structure Input where
  queryType : String
  query     : String
  deriving DecidableEq, Repr

structure Output where
  sentToAdmin : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => true
  post := fun i o => o.sentToAdmin = true

example : Spec.pre { queryType := "technical", query := "How to use the system?" } ∧
          Spec.post { queryType := "technical", query := "How to use the system?" } { sentToAdmin := true } := by
  unfold Spec; decide
