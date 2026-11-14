import ContractForge
open ContractForge

-- 5.2.3.27: 5.2.3.27 Where the driver is required to enter the train number information, the information entered shall be shown on the display and require confirmation by the driver before further actions are possible. (M)

-- L0 spec

structure Input where
  trainNumber : String
  deriving DecidableEq, Repr

structure Output where
  displayed : String
  confirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.trainNumber ≠ ""
  post := fun i o => o.displayed = i.trainNumber ∧
                     (o.confirmed = true ↔ o.displayed = i.trainNumber) ∧
                     (o.confirmed = false → o.displayed = i.trainNumber)

example : Spec.pre { trainNumber := "12345" } ∧
          Spec.post { trainNumber := "12345" }
                    { displayed := "12345", confirmed := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { displayed := x.trainNumber,
    confirmed := decide (x.trainNumber = x.trainNumber) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
