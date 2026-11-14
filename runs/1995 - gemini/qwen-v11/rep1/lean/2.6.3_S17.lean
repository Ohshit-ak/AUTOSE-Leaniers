import ContractForge
open ContractForge

-- 2.6.3/S17: However it must be recognized that:
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  visitorId : String
  deriving DecidableEq, Repr

structure Output where
  recognized : Bool
  message    : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.visitorId ≠ ""
  post := fun i o => (o.recognized = true ↔ i.visitorId = "1234567890") ∧
                     (o.recognized = false → o.message = "Visitor not recognized")

example : Spec.pre { visitorId := "1234567890" } ∧
          Spec.post { visitorId := "1234567890" }
                    { recognized := true, message := "" } := by
  unfold Spec; decide
