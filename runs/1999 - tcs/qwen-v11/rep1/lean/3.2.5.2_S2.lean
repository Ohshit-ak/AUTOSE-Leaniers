import ContractForge
open ContractForge

-- 3.2.5.2/S2: Processing will include formatting, storing, routing, and display.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  data : String
  format : String
  deriving DecidableEq, Repr

structure Output where
  formatted : String
  stored : Bool
  routed : Bool
  displayed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.format ≠ ""
  post := fun i o => 
    o.formatted = i.format ∧
    o.stored = true ∧
    o.routed = true ∧
    o.displayed = true ∧
    (o.formatted = i.format ↔ true) ∧
    (o.stored = true ↔ true) ∧
    (o.routed = true ↔ true) ∧
    (o.displayed = true ↔ true)

example : Spec.pre { data := "example", format := "JSON" } ∧
          Spec.post { data := "example", format := "JSON" }
                    { formatted := "JSON", stored := true, routed := true, displayed := true } := by
  unfold Spec; decide
