import ContractForge
open ContractForge

-- 13.4.8: 13.4.8 The performance of the confirmation procedure shall not be dependent upon the current use of the mobile and shall not overload the network. (M)

-- L0 spec

structure Input where
  emergencyCallId : Nat
  mobileStatus    : String
  networkLoad     : Nat
  deriving DecidableEq, Repr

structure Output where
  confirmationSent : Bool
  networkLoadAfter : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mobileStatus ≠ "in use" ∧ 0 < i.networkLoad
  post := fun i o => o.confirmationSent = true ∧
                     o.networkLoadAfter = i.networkLoad - 1

example : Spec.pre { emergencyCallId := 123, mobileStatus := "not in use", networkLoad := 50 } ∧
          Spec.post { emergencyCallId := 123, mobileStatus := "not in use", networkLoad := 50 }
                    { confirmationSent := true, networkLoadAfter := 49 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { confirmationSent := true,
    networkLoadAfter := x.networkLoad - 1 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
