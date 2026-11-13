import ContractForge
open ContractForge

-- 3.4.3/S1: The TCS shall provide an internal interface for the SAR Processor in order to disseminate SAR information (to include imagery and telemetry) to other components of the TCS. [SSS330] The SAR Processor interface requirements and specifications will be defined in the TCS to SAR Processor IDD, TCS 240.

-- L0 spec

structure Input where
  sarInfo : String
  deriving DecidableEq, Repr

structure Output where
  disseminated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.sarInfo ≠ ""
  post := fun i o => o.disseminated = true ∧
                     (o.disseminated = true ↔
                      -- IMPL: TCS to SAR Processor IDD, TCS 240
                      true)

example : Spec.pre { sarInfo := "SAR data" } ∧
          Spec.post { sarInfo := "SAR data" }
                    { disseminated := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { disseminated := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
