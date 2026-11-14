import ContractForge
open ContractForge

-- 13.2.3/S1: It shall be possible to configure Railway emergency group call areas to contain combinations of cells controlled by one or more MSC(s) within one or more network(s).
-- compiles: False · rejects_bad_example: None · checked: False

structure Cell where
  id : Nat
  deriving DecidableEq, Repr

structure MSC where
  id : Nat
  cells : List Cell
  deriving DecidableEq, Repr

structure Network where
  id : Nat
  mscs : List MSC
  deriving DecidableEq, Repr

structure Input where
  networks : List Network
  deriving DecidableEq, Repr

structure Output where
  groups : List Network
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.networks.Nodup
  post := fun i o => o.groups.Nodup ∧
                     (∀ g ∈ o.groups, g.mscs.Nodup ∧
                      (∀ m ∈ g.mscs, m.cells.Nodup) ∧
                      (∀ m1 m2 ∈ g.mscs, m1 ≠ m2 → m1.cells.Nodup ∧ m2.cells.Nodup))

example : Spec.pre { networks := [{ id := 1, mscs := [{ id := 1, cells := [{ id := 1 }] }] },
                                   { id := 2, mscs := [{ id := 2, cells := [{ id := 2 }] }] }] } ∧
          Spec.post { networks := [{ id := 1, mscs := [{ id := 1, cells := [{ id := 1 }] }] },
                                    { id := 2, mscs := [{ id := 2, cells := [{ id := 2 }] }] }] }
                    { groups := [{ id := 1, mscs := [{ id := 1, cells := [{ id := 1 }] }] },
                                 { id := 2, mscs := [{ id := 2, cells := [{ id := 2 }] }] }] } := by
  unfold Spec; decide
