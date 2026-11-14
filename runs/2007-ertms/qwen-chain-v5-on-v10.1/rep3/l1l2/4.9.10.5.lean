import ContractForge
open ContractForge

-- 4.9.10.5: The driver shall be able to use the Reversing function without needing to re-confirm the train data.

-- L0 spec

structure Input where
  trainData : String
  deriving DecidableEq, Repr

structure Output where
  trainData : String
  reversed  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.trainData ≠ ""
  post := fun i o => o.trainData = i.trainData ∧
                     o.reversed = true

example : Spec.pre { trainData := "12345" } ∧
          Spec.post { trainData := "12345" }
                    { trainData := "12345", reversed := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { trainData := x.trainData,
    reversed := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
