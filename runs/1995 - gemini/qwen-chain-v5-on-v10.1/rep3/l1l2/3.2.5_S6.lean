import ContractForge
open ContractForge

-- 3.2.5/S6: Operations staff have privileges to change the environment, meaning selecting a suitable combination of instrumentsThe operational software should know which subsystems are installed and operational at any given time.

-- L0 spec

structure Input where
  subsystems : List String
  deriving DecidableEq, Repr

structure Output where
  selected : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.subsystems.Nodup
  post := fun i o => o.selected.length ≤ i.subsystems.length ∧
                     (∀ s ∈ o.selected, s ∈ i.subsystems) ∧
                     (o.selected.Nodup ↔ o.selected.length = i.subsystems.length)

example : Spec.pre { subsystems := [] } ∧ Spec.post { subsystems := [] } { selected := [] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { selected := (x.subsystems.filter (fun s => decide (s ∈ x.subsystems))).take x.subsystems.length }
