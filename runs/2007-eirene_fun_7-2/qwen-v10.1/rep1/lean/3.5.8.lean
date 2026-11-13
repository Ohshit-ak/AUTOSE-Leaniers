import ContractForge
open ContractForge

-- 3.5.8: 3.5.8 Requirement 3.5.7 needs further technical specification changes before field implementation can be achieved. (I)
-- compiles: True · rejects_bad_example: True · checked: True

structure Area where
  type : String
  config : String
  deriving DecidableEq, Repr

structure Input where
  area : Area
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.area.type ∈ ["broadcast", "group"]
  post := fun i o =>
    o.valid = true ↔
    (i.area.type = "broadcast" →
      i.area.config = "configured for broadcast" ∧
      o.message = "Area is correctly configured for broadcast")
    ∧
    (i.area.type = "group" →
      i.area.config = "configured for group call" ∧
      o.message = "Area is correctly configured for group call")

example : Spec.pre { area := { type := "broadcast", config := "configured for broadcast" } } ∧
          Spec.post { area := { type := "broadcast", config := "configured for broadcast" } }
                    { valid := true, message := "Area is correctly configured for broadcast" } := by
  unfold Spec; decide
