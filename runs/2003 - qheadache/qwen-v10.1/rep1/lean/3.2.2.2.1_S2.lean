import ContractForge
open ContractForge

-- 3.2.2.2.1/S2: Enter your name : ", an Edit Box that can contain 20 characters and a pushbutton with the label "OK".
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  name : String
  deriving DecidableEq, Repr

structure Output where
  name : String
  statistics : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name.length ≤ 20
  post := fun i o => o.name = i.name ∧
                     (o.statistics = "Game finished. Your name: " ++ i.name)

example : Spec.pre { name := "Alice" } ∧
          Spec.post { name := "Alice" }
                    { name := "Alice", statistics := "Game finished. Your name: Alice" } := by
  unfold Spec; decide
