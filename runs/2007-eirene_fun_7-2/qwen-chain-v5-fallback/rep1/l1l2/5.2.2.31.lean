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
  terminating : Bool
  deriving DecidableEq, Repr

structure Output where
  leadDriver : Bool
  active     : Bool
  terminating : Bool
  callTerminated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.leadDriver = true ∧ i.active = true
  post := fun i o => (o.callTerminated = true ↔ o.terminating = true) ∧
                     (o.callTerminated = true → o.active = false) ∧
                     o.leadDriver = i.leadDriver ∧
                     o.active = false ∧
                     o.terminating = i.terminating

example : Spec.pre { leadDriver := true, active := true, terminating := true } ∧
          Spec.post { leadDriver := true, active := true, terminating := true }
                     { leadDriver := true, active := false, terminating := true, callTerminated := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { leadDriver := x.leadDriver,
    active := false,
    terminating := x.terminating,
    callTerminated := decide (x.terminating = true) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
