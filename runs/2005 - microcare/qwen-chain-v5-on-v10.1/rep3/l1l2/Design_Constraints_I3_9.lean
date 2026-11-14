import ContractForge
open ContractForge

-- Design Constraints/I3#9: The system should save the user information only if the Password and Verify password values are equal

-- L0 spec

structure Input where
  password  : String
  verifyPassword : String
  deriving DecidableEq, Repr

structure Output where
  saved : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.password = i.verifyPassword
  post := fun i o => o.saved = true

example : Spec.pre { password := "test123", verifyPassword := "test123" } ∧
          Spec.post { password := "test123", verifyPassword := "test123" }
                    { saved := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { saved := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
