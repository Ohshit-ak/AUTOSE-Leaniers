import ContractForge
open ContractForge

-- UC-administrator-remove-plug-ins: Remove Plug-ins: Remove a plug-in from the application.

-- L0 spec

structure PlugIn where
  name : String
  active : Bool
  deriving DecidableEq, Repr

structure Input where
  plugIns : List PlugIn
  name    : String
  deriving DecidableEq, Repr

structure Output where
  plugIns : List PlugIn
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ i.plugIns.Nodup
  post := fun i o => 
    (∃ p ∈ i.plugIns, p.name = i.name ∧ p.active = true) →
    o.plugIns = i.plugIns.filter (fun p => p.name ≠ i.name) ∧
    o.plugIns.Nodup

example : Spec.pre { plugIns := [{ name := "plug1", active := true },
                                  { name := "plug2", active := true }],
                     name := "plug1" } ∧
          Spec.post { plugIns := [{ name := "plug1", active := true },
                                  { name := "plug2", active := true }],
                      name := "plug1" }
                    { plugIns := [{ name := "plug2", active := true }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { plugIns := x.plugIns.filter (fun p => p.name = x.name ∧ p.active) }
