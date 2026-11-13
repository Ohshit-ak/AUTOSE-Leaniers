import ContractForge
open ContractForge

-- 3.4.2.8/S8: Requirement The PEPPOL infrastructure SHOULD have the capability to submit a bid which contains a VCD.

-- L0 spec

structure Input where
  bid : String
  vcd : String
  deriving DecidableEq, Repr

structure Output where
  submitted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.submitted = true ↔
    (i.vcd ≠ "" ∧ i.bid ≠ "")

example : Spec.pre { bid := "BID123", vcd := "VCD456" } ∧
          Spec.post { bid := "BID123", vcd := "VCD456" }
                    { submitted := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { submitted := x.vcd ≠ "" ∧ x.bid ≠ "" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
