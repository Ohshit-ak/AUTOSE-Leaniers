import ContractForge
open ContractForge

-- 1./S2: The created unique numbers are then printed out in the form of bar-codes, which will complement (or stuck on the voucher) the voucher.
-- compiles: True · rejects_bad_example: True · checked: True

structure Voucher where
  number : Nat
  barcode : String
  deriving DecidableEq, Repr

structure Input where
  numbers : List Nat
  deriving DecidableEq, Repr

structure Output where
  barcodes : List Voucher
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.numbers.Nodup
  post := fun i o => o.barcodes.length = i.numbers.length ∧
                     ∀ n ∈ i.numbers, ∃ v ∈ o.barcodes, v.number = n ∧
                     v.barcode ≠ ""

example : Spec.pre { numbers := [12345, 67890] } ∧
          Spec.post { numbers := [12345, 67890] }
                    { barcodes := [{ number := 12345, barcode := "12345" },
                                   { number := 67890, barcode := "67890" }] } := by
  unfold Spec; decide
