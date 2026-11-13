import ContractForge
open ContractForge

-- 2.1.1/I1: The VMU will create the vouchers and sell it to clients through distributors
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  vouchersCreated : Nat
  deriving DecidableEq, Repr

structure Output where
  vouchersSold : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.vouchersCreated > 0
  post := fun i o => o.vouchersSold = i.vouchersCreated

example : Spec.pre { vouchersCreated := 10 } ∧
          Spec.post { vouchersCreated := 10 } { vouchersSold := 10 } := by
  unfold Spec; decide
