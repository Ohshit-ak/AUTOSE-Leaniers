import ContractForge
open ContractForge

-- 3.5.8: 3.5.8 Requirement 3.5.7 needs further technical specification changes before field implementation can be achieved. (I)
-- compiles: True · rejects_bad_example: None · checked: True

structure Area where
  id : Nat
  type : String
  deriving DecidableEq, Repr

structure Input where
  areas : List Area
  deriving DecidableEq, Repr

structure Output where
  areas : List Area
  deriving DecidableEq, Repr

-- An area can be either "broadcast" or "group"
def Spec : Contract Input Output where
  pre  := fun i => i.areas.Nodup ∧
                  i.areas.all (fun a => a.type = "broadcast" ∨ a.type = "group")
  post := fun i o => o.areas = i.areas.filter (fun a => a.type = "broadcast" ∨ a.type = "group")

example : Spec.pre { areas := [{ id := 1, type := "broadcast" },
                                { id := 2, type := "group" }] } ∧
          Spec.post { areas := [{ id := 1, type := "broadcast" },
                                 { id := 2, type := "group" }] }
                    { areas := [{ id := 1, type := "broadcast" },
                                { id := 2, type := "group" }] } := by
  unfold Spec; decide
