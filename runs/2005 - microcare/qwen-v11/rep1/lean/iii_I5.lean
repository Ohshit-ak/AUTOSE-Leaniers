import ContractForge
open ContractForge

-- iii/I5: According to the number of vouchers required by the distributor, the system should allocate the relevant vouchers with their numbers and batch numbers based on the stock.
-- compiles: True · rejects_bad_example: None · checked: True

structure Voucher where
  number : Nat
  batch  : Nat
  deriving DecidableEq, Repr

structure Input where
  distributorId : Nat
  requiredCount : Nat
  vouchersStock : List Voucher
  deriving DecidableEq, Repr

structure Output where
  allocatedCount : Nat
  allocatedVouchers : List Voucher
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.requiredCount ≤ i.vouchersStock.length
  post := fun i o => o.allocatedCount = i.requiredCount ∧
                     o.allocatedVouchers.length = i.requiredCount ∧
                     (∀ v ∈ o.allocatedVouchers, v ∈ i.vouchersStock) ∧
                     (∀ v ∈ i.vouchersStock, v ∈ o.allocatedVouchers → v.batch = v.batch)

example : Spec.pre { distributorId := 1, requiredCount := 5,
                     vouchersStock := [{ number := 1, batch := 100 },
                                       { number := 2, batch := 101 },
                                       { number := 3, batch := 102 },
                                       { number := 4, batch := 103 },
                                       { number := 5, batch := 104 },
                                       { number := 6, batch := 105 }] } ∧
          Spec.post { distributorId := 1, requiredCount := 5,
                      vouchersStock := [{ number := 1, batch := 100 },
                                        { number := 2, batch := 101 },
                                        { number := 3, batch := 102 },
                                        { number := 4, batch := 103 },
                                        { number := 5, batch := 104 },
                                        { number := 6, batch := 105 }] }
                    { allocatedCount := 5, allocatedVouchers := [{ number := 1, batch := 100 },
                                                                  { number := 2, batch := 101 },
                                                                  { number := 3, batch := 102 },
                                                                  { number := 4, batch := 103 },
                                                                  { number := 5, batch := 104 }] } := by
  unfold Spec; decide
