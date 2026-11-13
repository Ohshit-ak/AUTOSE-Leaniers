import ContractForge
open ContractForge

-- 7.2.2.14: 7.2.2.14 Where available, the functional identity of the calling party shall be displayed. (M) Receive incoming group or broadcast voice call

-- L0 spec

structure Input where
  callerId : String
  deriving DecidableEq, Repr

structure Output where
  callerId : String
  displayed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callerId ≠ ""
  post := fun i o => o.displayed = true ∧ o.callerId = i.callerId

example : Spec.pre { callerId := "Radio1" } ∧
          Spec.post { callerId := "Radio1" }
                    { displayed := true, callerId := "Radio1" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { callerId := x.callerId, displayed := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
