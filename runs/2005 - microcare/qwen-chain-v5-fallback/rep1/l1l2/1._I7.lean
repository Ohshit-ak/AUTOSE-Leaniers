import ContractForge
open ContractForge

-- 1./I7: Additionally the provision for validity date check for the period of vouchers to be used in the program is provided. This validity date can be amended or altered at the system level ONLY by the authorized user

-- L0 spec

structure Input where
  voucherId : Nat
  validityDate : String
  isAuthorized : Bool
  deriving DecidableEq, Repr

structure Output where
  voucherId : Nat
  validityDate : String
  isAuthorized : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.isAuthorized
  post := fun i o => o.voucherId = i.voucherId ∧
                     (o.validityDate = i.validityDate ↔ i.isAuthorized) ∧
                     o.isAuthorized = i.isAuthorized

example : Spec.pre { voucherId := 1, validityDate := "2023-12-31", isAuthorized := true } ∧ Spec.post { voucherId := 1, validityDate := "2023-12-31", isAuthorized := true } { voucherId := 1, validityDate := "2023-12-31", isAuthorized := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { voucherId := x.voucherId,
    validityDate := if x.isAuthorized then x.validityDate else "default validity date",
    isAuthorized := x.isAuthorized }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
