import ContractForge
open ContractForge

-- 13.5.6/S1: The user information contained in the confirmation message shall be: (M)

-- L0 spec

structure Input where
  emergencyCallId : String
  userInformation : String
  deriving DecidableEq, Repr

structure Output where
  confirmationMessage : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.userInformation ≠ ""
  post := fun i o => o.confirmationMessage = i.emergencyCallId ++ " - " ++ i.userInformation

example : Spec.pre { emergencyCallId := "EC1234", userInformation := "User A" } ∧
          Spec.post { emergencyCallId := "EC1234", userInformation := "User A" }
                    { confirmationMessage := "EC1234 - User A" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { confirmationMessage := x.emergencyCallId ++ " - " ++ x.userInformation }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
