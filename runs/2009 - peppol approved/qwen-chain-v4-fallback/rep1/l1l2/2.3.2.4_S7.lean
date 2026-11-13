import ContractForge
open ContractForge

-- 2.3.2.4/S7: Economic operator data is data that can initially be provided by an economic operator (e.g. company registration number, VAT number, social insurance number of the company etc.) to start the VCD packaging service.

-- L0 spec

structure Input where
  companyRegNum : Option String
  vatNum        : Option String
  socialInsNum  : Option String
  deriving DecidableEq, Repr

structure Output where
  accepted     : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.companyRegNum.isSome ∨ i.vatNum.isSome ∨ i.socialInsNum.isSome
  post := fun i o => o.accepted = true ↔ (i.companyRegNum.isSome ∨ i.vatNum.isSome ∨ i.socialInsNum.isSome)

example : Spec.pre { companyRegNum := some "123456789", vatNum := none, socialInsNum := none } ∧
          Spec.post { companyRegNum := some "123456789", vatNum := none, socialInsNum := none }
                    { accepted := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { accepted := decide (x.companyRegNum.isSome ∨ x.vatNum.isSome ∨ x.socialInsNum.isSome) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
