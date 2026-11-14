import ContractForge
open ContractForge

-- 13.5.9/S1: The user-to-user information elements in the following messages, as defined in [EN 301 515, Index [16]], shall be used for the confirmation of high priority calls: (M)

-- L0 spec

structure Input where
  message : String
  deriving DecidableEq, Repr

structure Output where
  confirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.message ≠ ""
  post := fun i o => o.confirmed = true ↔
    (i.message = "M" ∨
     i.message = "m" ∨
     i.message = "Emergency call confirmed" ∨
     i.message = "Emergency call confirmed in progress")

example : Spec.pre { message := "M" } ∧
          Spec.post { message := "M" } { confirmed := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { confirmed := decide ((x.message = "M" ∨
     x.message = "m" ∨
     x.message = "Emergency call confirmed" ∨
     x.message = "Emergency call confirmed in progress")) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
