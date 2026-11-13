import ContractForge
open ContractForge

-- UC-administrator-remove-plug-ins: Remove Plug-ins: Remove a plug-in from the application.

-- L0 spec

structure PlugIn where
  name : String
  version : String
  deriving DecidableEq, Repr

structure Input where
  plugIns : List PlugIn
  plugInName : String
  deriving DecidableEq, Repr

structure Output where
  plugIns : List PlugIn
  removed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.plugInName ≠ ""
  post := fun i o => o.removed = true ∧
                     (∀ p ∈ i.plugIns, p.name ≠ i.plugInName) ∧
                     o.plugIns = i.plugIns.filter (fun p => p.name ≠ i.plugInName)

example : Spec.pre { plugIns := [], plugInName := "plugin1" } ∧ Spec.post { plugIns := [], plugInName := "plugin1" } { plugIns := [], removed := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { plugIns := x.plugIns.filter (fun p => p.name ≠ x.plugInName), removed := true }
