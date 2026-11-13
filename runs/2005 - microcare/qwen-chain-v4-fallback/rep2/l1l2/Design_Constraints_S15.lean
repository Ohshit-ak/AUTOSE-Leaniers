import ContractForge
open ContractForge

-- Design Constraints/S15: The allowed users only can able to Add, Modify or delete the VSP master information including payment terms.

-- L0 spec

structure VSP where
  name    : String
  terms   : String
  deriving DecidableEq, Repr

structure Input where
  vsp     : Option VSP
  action  : String
  deriving DecidableEq, Repr

structure Output where
  vsp     : Option VSP
  action  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.action ∈ ["Add", "Modify", "Delete"]
  post := fun i o => (o.action = i.action) ∧
                     (o.vsp = i.vsp ∨
                      (o.action = "Add" → o.vsp.isSome ∧ o.vsp.getD { name := "", terms := "" } ≠ i.vsp.getD { name := "", terms := "" }) ∧
                      (o.action = "Modify" → o.vsp = i.vsp ∨ o.vsp.getD { name := "", terms := "" } ≠ i.vsp.getD { name := "", terms := "" }) ∧
                      (o.action = "Delete" → o.vsp = none))

example : Spec.pre { vsp := none, action := "Add" } ∧
          Spec.post { vsp := none, action := "Add" }
                    { vsp := some { name := "VSP1", terms := "30 days" }, action := "Add" } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { vsp := x.vsp,
    action := x.action }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
