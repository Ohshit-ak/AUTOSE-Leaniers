import ContractForge
open ContractForge

-- 3.11.1/S1: The user can modify the context of an entry he already has added.

-- L0 spec

structure Entry where
  description : String
  context     : String
  index       : Nat
  deriving DecidableEq, Repr

structure Input where
  entries : List Entry
  index   : Nat
  newContext : String
  deriving DecidableEq, Repr

structure Output where
  entries : List Entry
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.index < i.entries.length
  post := fun i o => o.entries = i.entries.map (fun e => if e.index = i.index then { e with context := i.newContext } else e)

example : Spec.pre { entries := [{ description := "test", context := "old", index := 0 }],
                     index := 0, newContext := "new" } ∧
          Spec.post { entries := [{ description := "test", context := "old", index := 0 }],
                      index := 0, newContext := "new" }
                    { entries := [{ description := "test", context := "new", index := 0 }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { entries := x.entries.map (fun e => if e.index = x.index then { e with context := x.newContext } else e) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
