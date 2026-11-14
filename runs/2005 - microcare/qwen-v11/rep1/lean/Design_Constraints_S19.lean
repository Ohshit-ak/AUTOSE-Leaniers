import ContractForge
open ContractForge

-- Design Constraints/S19: Cumulative Total Amount will show in Report footer for the previous payment done.
-- compiles: True · rejects_bad_example: True · checked: True

structure PaymentRecord where
  voucherId : Nat
  amount    : Nat
  deriving DecidableEq, Repr

structure Report where
  footer : PaymentRecord
  deriving DecidableEq, Repr

structure Input where
  previousPayments : List PaymentRecord
  deriving DecidableEq, Repr

structure Output where
  footer : PaymentRecord
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.previousPayments.Nodup ∧ (i.previousPayments.map (·.amount)).sum ≠ 0
  post := fun i o => o.footer = { voucherId := 0, amount := (i.previousPayments.map (·.amount)).sum }

example : Spec.pre { previousPayments := [{ voucherId := 1, amount := 100 },
                                          { voucherId := 2, amount := 200 },
                                          { voucherId := 3, amount := 300 }] } ∧
          Spec.post { previousPayments := [{ voucherId := 1, amount := 100 },
                                           { voucherId := 2, amount := 200 },
                                           { voucherId := 3, amount := 300 }] }
                    { footer := { voucherId := 0, amount := 600 } } := by
  unfold Spec; decide
