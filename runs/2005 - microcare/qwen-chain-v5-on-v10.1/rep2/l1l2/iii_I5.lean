import ContractForge
open ContractForge

-- iii/I5: According to the number of vouchers required by the distributor, the system should allocate the relevant vouchers with their numbers and batch numbers based on the stock.

-- L0 spec

structure Voucher where
  number : Nat
  batchNumber : Nat
  deriving DecidableEq, Repr

structure Input where
  vouchersRequired : Nat
  vouchersStock : List Voucher
  deriving DecidableEq, Repr

structure Output where
  vouchersAllocated : List Voucher
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.vouchersRequired ≤ i.vouchersStock.length
  post := fun i o => o.vouchersAllocated.length = i.vouchersRequired ∧
                     (∀ v ∈ o.vouchersAllocated, v ∈ i.vouchersStock ∧
                      ∃ v' ∈ i.vouchersStock, v = v' ∧ v.batchNumber = v'.batchNumber)

example : Spec.pre { vouchersRequired := 3, vouchersStock := [{ number := 101, batchNumber := 1001 },
                                                              { number := 102, batchNumber := 1002 },
                                                              { number := 103, batchNumber := 1003 }] } ∧
          Spec.post { vouchersRequired := 3, vouchersStock := [{ number := 101, batchNumber := 1001 },
                                                                { number := 102, batchNumber := 1002 },
                                                                { number := 103, batchNumber := 1003 }] }
                    { vouchersAllocated := [{ number := 101, batchNumber := 1001 },
                                            { number := 102, batchNumber := 1002 },
                                            { number := 103, batchNumber := 1003 }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { vouchersAllocated := x.vouchersStock.filter (fun v => 
    decide (v ∈ x.vouchersStock ∧ 
             ∃ v' ∈ x.vouchersStock, v = v' ∧ v.batchNumber = v'.batchNumber)) 
    .take x.vouchersRequired }
