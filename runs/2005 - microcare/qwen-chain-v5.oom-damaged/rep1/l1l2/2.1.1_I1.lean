import ContractForge
open ContractForge

-- 2.1.1/I1: The VMU will create the vouchers and sell it to clients through distributors

-- L0 spec

structure Input where
  vouchersCreated : Nat
  deriving DecidableEq, Repr

structure Output where
  vouchersSold    : Nat
  distributors    : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.vouchersCreated
  post := fun i o => o.vouchersSold = i.vouchersCreated ∧
                     o.distributors.Nodup ∧
                     o.distributors.length > 0

example : Spec.pre { vouchersCreated := 10 } ∧
          Spec.post { vouchersCreated := 10 }
                    { vouchersSold := 10, distributors := ["D1", "D2", "D3"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { vouchersSold := x.vouchersCreated,
    distributors := "D1" :: "D2" :: List.nil }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
