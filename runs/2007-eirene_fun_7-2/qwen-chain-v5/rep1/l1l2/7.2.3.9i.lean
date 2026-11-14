import ContractForge
open ContractForge

-- 7.2.3.9i: 7.2.3.9i It shall be possible for a user to override the automatic network selection manually. This function shall not be available during calls. (M) Register and deregister functional number

-- L0 spec

structure Input where
  userRegistered : Bool
  manualOverride : Bool
  calling : Bool
  deriving DecidableEq, Repr

structure Output where
  manualOverride : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.userRegistered = true
  post := fun i o => (o.manualOverride = i.manualOverride ↔
    (i.calling = false ∧ i.manualOverride = true)) ∧
    (o.manualOverride = false → i.calling = true)

example : Spec.pre { userRegistered := true, manualOverride := false, calling := false } ∧ Spec.post { userRegistered := true, manualOverride := false, calling := false } { manualOverride := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { manualOverride := (x.calling = false ∧ x.manualOverride = true) }
