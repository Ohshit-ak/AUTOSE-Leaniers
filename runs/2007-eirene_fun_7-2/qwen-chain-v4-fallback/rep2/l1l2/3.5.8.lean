import ContractForge
open ContractForge

-- 3.5.8: 3.5.8 Requirement 3.5.7 needs further technical specification changes before field implementation can be achieved. (I)

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { valid := x.area.type ∈ ["broadcast", "group"],
    message := if x.area.type = "broadcast" then
                 if x.area.config = "configured for broadcast" then
                   "Area is correctly configured for broadcast"
                 else
                   "Area is not configured for broadcast"
               else
                 if x.area.type = "group" then
                   if x.area.config = "configured for group call" then
                     "Area is correctly configured for group call"
                   else
                     "Area is not configured for group call"
                 else
                   "Invalid area type"
  }
