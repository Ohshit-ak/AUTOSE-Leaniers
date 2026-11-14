import ContractForge
open ContractForge

-- 2.6.3/I6: maintenance of operations tables (such as filter lists) which can become part of an observation's permanent record

-- L0 spec

structure Operation where
  id     : Nat
  filter : List String
  deriving DecidableEq, Repr

structure Input where
  ops : List Operation
  deriving DecidableEq, Repr

structure Output where
  ops : List Operation
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.ops.Nodup
  post := fun i o => o.ops = i.ops.filter (fun op => op.filter.Nodup)

example : Spec.pre { ops := [{ id := 1, filter := ["a", "b"] },
                             { id := 2, filter := ["c"] }] } ∧
          Spec.post { ops := [{ id := 1, filter := ["a", "b"] },
                               { id := 2, filter := ["c"] }] }
                    { ops := [{ id := 1, filter := ["a", "b"] },
                              { id := 2, filter := ["c"] }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { ops := x.ops.filter (fun op => op.filter.Nodup) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
