import ContractForge
open ContractForge

-- 13.5.3/S1: Confirmation of Railway emergency calls shall be implemented using the User to User Signalling supplementary service (UUS1).

-- L0 spec

structure Input where
  callId : Nat
  emergency : Bool
  deriving DecidableEq, Repr

structure Output where
  confirmed : Bool
  deriving DecidableEq, Repr

-- IMPL: User to User Signalling supplementary service (UUS1)
def Spec : Contract Input Output where
  pre  := fun i => i.emergency = true
  post := fun i o => o.confirmed = true

example : Spec.pre { callId := 123, emergency := true } ∧
          Spec.post { callId := 123, emergency := true } { confirmed := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { confirmed := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
