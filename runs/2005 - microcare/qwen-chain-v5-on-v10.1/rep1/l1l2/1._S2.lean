import ContractForge
open ContractForge

-- 1./S2: The created unique numbers are then printed out in the form of bar-codes, which will complement (or stuck on the voucher) the voucher.

-- L0 spec

structure Voucher where
  number : Nat
  barCode : String
  deriving DecidableEq, Repr

structure Input where
  vouchers : List Voucher
  deriving DecidableEq, Repr

structure Output where
  vouchers : List Voucher
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.vouchers.all (fun v => v.number ≠ 0)
  post := fun i o => o.vouchers = i.vouchers ∧
                     o.vouchers.all (fun v => v.barCode ≠ "" ∧ v.barCode.length = 13)

example : Spec.pre { vouchers := [{ number := 12345, barCode := "1234567890123" },
                                   { number := 67890, barCode := "6789012345678" }] } ∧
          Spec.post { vouchers := [{ number := 12345, barCode := "1234567890123" },
                                    { number := 67890, barCode := "6789012345678" }] }
                    { vouchers := [{ number := 12345, barCode := "1234567890123" },
                                   { number := 67890, barCode := "6789012345678" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { vouchers := x.vouchers.filter (fun v => v.barCode ≠ "" ∧ v.barCode.length = 13) }
