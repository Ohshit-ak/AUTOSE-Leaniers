import ContractForge
open ContractForge

-- 4.8.8.1: It shall be possible to send plain text messages from track to train.

-- L0 spec

structure Input where
  message : String
  deriving DecidableEq, Repr

structure Output where
  received : Bool
  message  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.message ≠ ""
  post := fun i o => o.received = true ∧ o.message = i.message

example : Spec.pre { message := "Hello, train!" } ∧
          Spec.post { message := "Hello, train!" }
                    { received := true, message := "Hello, train!" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { received := true, message := x.message }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
