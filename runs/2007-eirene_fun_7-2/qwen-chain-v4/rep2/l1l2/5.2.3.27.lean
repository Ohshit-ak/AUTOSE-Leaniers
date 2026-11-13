import ContractForge
open ContractForge

-- 5.2.3.27: 5.2.3.27 Where the driver is required to enter the train number information, the information entered shall be shown on the display and require confirmation by the driver before further actions are possible. (M)

-- L0 spec

structure Input where
  trainNumber : String
  deriving DecidableEq, Repr

structure Output where
  displayed : String
  confirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.trainNumber ≠ ""
  post := fun i o => o.displayed = i.trainNumber ∧
                     (o.confirmed = true ↔ o.displayed = i.trainNumber)

example : Spec.pre { trainNumber := "12345" } ∧
          Spec.post { trainNumber := "12345" }
                    { displayed := "12345", confirmed := true } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  displayed : String
  deriving DecidableEq, Repr

def ComputeDisplayedContract : Contract Input Mid where
  pre  := fun i => i.trainNumber ≠ ""
  post := fun i m => m.displayed = i.trainNumber

def ConfirmOrderContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.displayed = m.displayed ∧ (o.confirmed = true ↔ m.displayed = m.displayed)
