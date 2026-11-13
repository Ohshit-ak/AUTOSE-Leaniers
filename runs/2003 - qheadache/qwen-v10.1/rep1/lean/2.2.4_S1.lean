import ContractForge
open ContractForge

-- 2.2.4/S1: The product must record the score (time and number of counts) of a play associated with the name of a user.
-- compiles: True · rejects_bad_example: True · checked: True

structure Play where
  name  : String
  time  : Nat
  counts: Nat
  deriving DecidableEq, Repr

structure Input where
  user  : String
  play  : Play
  deriving DecidableEq, Repr

structure Output where
  user  : String
  play  : Play
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.user ≠ ""
  post := fun i o => o.user = i.user ∧
                     o.play.name = i.play.name ∧
                     o.play.time = i.play.time ∧
                     o.play.counts = i.play.counts

example : Spec.pre { user := "alice", play := { name := "level1", time := 120, counts := 5 } } ∧
          Spec.post { user := "alice", play := { name := "level1", time := 120, counts := 5 } }
                    { user := "alice", play := { name := "level1", time := 120, counts := 5 } } := by
  unfold Spec; decide
