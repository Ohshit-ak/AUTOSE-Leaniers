import ContractForge
open ContractForge

-- 3.2.5/S6: Operations staff have privileges to change the environment, meaning selecting a suitable combination of instrumentsThe operational software should know which subsystems are installed and operational at any given time.
-- compiles: True · rejects_bad_example: True · checked: True

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
                     (o.selected.Nodup ↔ o.selected.length = i.subsystems.length) ∧
                     (o.selected = i.subsystems → o.selected.length = i.subsystems.length) ∧
                     (o.selected ≠ i.subsystems → o.selected.length < i.subsystems.length)

example : Spec.pre { subsystems := ["A", "B", "C"] } ∧ Spec.post { subsystems := ["A", "B", "C"] } { selected := ["A", "B", "C"] } := by
  unfold Spec; decide
