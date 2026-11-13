import ContractForge
open ContractForge

-- 5.2.2.62: 5.2.2.62 The Cab radio system shall be able to receive incoming text messages (see section 12 for details). (M) Enter/leave shunting mode

-- L0 spec

structure Input where
  shuntingMode : Bool
  deriving DecidableEq, Repr

structure Output where
  shuntingMode : Bool
  message      : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.shuntingMode = true
  post := fun i o => o.shuntingMode = false ∧
                     (o.message = "Shunting mode exited." ↔ o.shuntingMode = false)

example : Spec.pre { shuntingMode := true } ∧
          Spec.post { shuntingMode := true }
                    { shuntingMode := false, message := "Shunting mode exited." } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { shuntingMode := false, message := "Shunting mode exited." }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
