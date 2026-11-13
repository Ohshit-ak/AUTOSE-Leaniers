import ContractForge
open ContractForge

-- 3.5.9/S6: The software must be strictly modular, i.e. the functionality of a subsystem should correspond to that which belongs to that subsystem and only to that, so that software for different subsystems can be installed and maintained independently of all the rest.This is needed in particular for multi-instrument operation, for example, as instruments share the same subsystems on the telescope.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  subsystemA : Nat
  subsystemB : Nat
  subsystemC : Nat
  deriving DecidableEq, Repr

structure Output where
  subsystemA : Nat
  subsystemB : Nat
  subsystemC : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.subsystemA = i.subsystemA ∧
                     o.subsystemB = i.subsystemB ∧
                     o.subsystemC = i.subsystemC

example : Spec.pre { subsystemA := 5, subsystemB := 10, subsystemC := 15 } ∧
          Spec.post { subsystemA := 5, subsystemB := 10, subsystemC := 15 }
                    { subsystemA := 5, subsystemB := 10, subsystemC := 15 } := by
  unfold Spec; decide
