import ContractForge
open ContractForge

-- Design Constraints/I3: Once created vouchers will not be edited or deleted but there will be a provision to with-hold any voucher number if the admin team decides to do for any reason.
-- compiles: True · rejects_bad_example: True · checked: True

structure Voucher where
  number : Nat
  deriving DecidableEq, Repr

structure Input where
  voucherNumbers : List Nat
  withholding    : Option Nat
  deriving DecidableEq, Repr

structure Output where
  voucherNumbers : List Nat
  withholding    : Option Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.voucherNumbers = i.voucherNumbers ∧
                     o.withholding = i.withholding

example : Spec.pre { voucherNumbers := [1, 2, 3], withholding := none } ∧
          Spec.post { voucherNumbers := [1, 2, 3], withholding := none }
                    { voucherNumbers := [1, 2, 3], withholding := none } := by
  unfold Spec; decide
