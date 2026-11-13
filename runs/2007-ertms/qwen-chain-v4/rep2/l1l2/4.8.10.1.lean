import ContractForge
open ContractForge

-- 4.8.10.1: It shall be possible to send information regarding the inhibition of the following different types of brake: Regenerative brake Eddy current brake Magnetic shoe brake

-- L0 spec

structure Input where
  brakeType : String
  inhibited : Bool
  deriving DecidableEq, Repr

structure Output where
  brakeType : String
  inhibited : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.brakeType ∈ ["Regenerative brake", "Eddy current brake", "Magnetic shoe brake"]
  post := fun i o => o.brakeType = i.brakeType ∧ o.inhibited = i.inhibited

example : Spec.pre { brakeType := "Regenerative brake", inhibited := true } ∧
          Spec.post { brakeType := "Regenerative brake", inhibited := true }
                     { brakeType := "Regenerative brake", inhibited := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { brakeType := x.brakeType, inhibited := x.inhibited }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
