import ContractForge
open ContractForge

-- 3.3.1/S6: Given the requirement to be able to access the Gemini 8m Telescopes from several points, the user interface should rather be seen as a package to be callable from a large number of stations, depending on where a user is.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  station : String
  telescope : String
  deriving DecidableEq, Repr

structure Output where
  accessible : Bool
  telescope : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.station ≠ ""
  post := fun i o => (o.accessible = true ↔
    (o.telescope = "Gemini 8m" ∧
     (i.station = "Station A" ∨ i.station = "Station B" ∨ i.station = "Station C"))) ∧
    (o.accessible = false → o.telescope = i.telescope) ∧
    (o.telescope = "" ↔ o.accessible = false)

example : Spec.pre { station := "Station A", telescope := "Gemini 8m" } ∧
          Spec.post { station := "Station A", telescope := "Gemini 8m" }
                    { accessible := true, telescope := "Gemini 8m" } := by
  unfold Spec; decide
