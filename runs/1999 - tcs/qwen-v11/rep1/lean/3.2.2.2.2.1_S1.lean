import ContractForge
open ContractForge

-- 3.2.2.2.2.1/S1: The TCS shall display the current search footprint and the search history of the payload on the map. [SSS157]
-- compiles: False · rejects_bad_example: None · checked: False

structure SearchFootprint where
  footprint : String
  deriving DecidableEq, Repr

structure SearchHistory where
  history : List String
  deriving DecidableEq, Repr

structure Input where
  footprint : SearchFootprint
  history   : SearchHistory
  deriving DecidableEq, Repr

structure Output where
  footprint : SearchFootprint
  history   : SearchHistory
  mapDisplay : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.footprint ≠ "" ∧ i.history.history.Nodup
  post := fun i o => o.footprint = i.footprint ∧
                     o.history = i.history ∧
                     o.mapDisplay = i.footprint.footprint ++ " " ++ i.history.history.foldl (fun acc s => acc ++ ", " ++ s) ""

example : Spec.pre { footprint := { footprint := "footprint1" }, history := { history := ["history1", "history2"] } } ∧
          Spec.post { footprint := { footprint := "footprint1" }, history := { history := ["history1", "history2"] } }
                    { footprint := { footprint := "footprint1" }, history := { history := ["history1", "history2"] }, mapDisplay := "footprint1, history1, history2" } := by
  unfold Spec; decide
