import ContractForge
open ContractForge

-- 5.2.2.31: 5.2.2.31 The lead driver shall be able to terminate the entire call. (M)

-- L0 spec

structure Call where
  leadDriver : Bool
  active     : Bool
  deriving DecidableEq, Repr

structure Input where
  leadDriver : Bool
  active     : Bool
  terminatingDriver : Bool
  deriving DecidableEq, Repr

structure Output where
  leadDriver : Bool
  active     : Bool
  terminated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.leadDriver = true ∧ i.active = true
  post := fun i o => (o.terminated = true ↔ i.leadDriver = true ∧ i.active = true ∧ i.terminatingDriver = true) ∧
                     (o.terminated = false ↔ i.leadDriver = true ∧ i.active = true ∧ i.terminatingDriver = false)

example : Spec.pre { leadDriver := true, active := true, terminatingDriver := true } ∧
          Spec.post { leadDriver := true, active := true, terminatingDriver := true }
                     { leadDriver := true, active := true, terminated := true } := by
  unfold Spec; decide

example : Spec.pre { leadDriver := true, active := true, terminatingDriver := false } ∧
          Spec.post { leadDriver := true, active := true, terminatingDriver := false }
                     { leadDriver := true, active := true, terminated := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { leadDriver := x.leadDriver, active := x.active, terminated := x.terminatingDriver }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
