import ContractForge
open ContractForge

-- 2.2.4/S1: The product must record the score (time and number of counts) of a play associated with the name of a user.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { user := x.user,
    play := { name := x.play.name, time := x.play.time, counts := x.play.counts } }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
