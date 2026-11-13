import ContractForge
open ContractForge

-- Design Constraints/S19: Cumulative Total Amount will show in Report footer for the previous payment done.
-- compiles: False · rejects_bad_example: None · checked: False

structure PaymentRecord where
  amount : Nat
  deriving DecidableEq, Repr

structure Report where
  footer : Option PaymentRecord
  deriving DecidableEq, Repr

structure Input where
  previousPayments : List PaymentRecord
  deriving DecidableEq, Repr

structure Output where
  report : Report
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.previousPayments.Nodup
  post := fun i o => o.report.footer = i.previousPayments.lastOption

example : Spec.pre { previousPayments := [{ amount := 100 }, { amount := 200 }] } ∧
          Spec.post { previousPayments := [{ amount := 100 }, { amount := 200 }] }
                    { report := { footer := some { amount := 200 } } } := by
  unfold Spec; decide
