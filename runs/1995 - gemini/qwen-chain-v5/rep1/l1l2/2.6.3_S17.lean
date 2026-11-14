import ContractForge
open ContractForge

-- 2.6.3/S17: However it must be recognized that:

-- L0 spec

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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  recognized : Bool
  deriving DecidableEq, Repr

def RecognizeVisitorContract : Contract Input Mid where
  pre  := fun i => i.visitorId ≠ ""
  post := fun i m => m.recognized = true ↔ i.visitorId = "1234567890"

def FormatMessageContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => m.recognized = true → o.recognized = true ∧ o.message = ""
         ∧ m.recognized = false → o.recognized = false ∧ o.message = "Visitor not recognized"
