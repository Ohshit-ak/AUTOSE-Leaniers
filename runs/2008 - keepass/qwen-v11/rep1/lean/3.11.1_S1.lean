import ContractForge
open ContractForge

-- 3.11.1/S1: The user can modify the context of an entry he already has added.
-- compiles: True · rejects_bad_example: None · checked: True

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
