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

-- L1 architecture (mode=chain, success=True)

structure Mid where
  recognized : Bool
  deriving DecidableEq, Repr

def RecognizeVisitorContract : Contract Input Mid where
  pre  := fun i => i.visitorId ≠ ""
  post := fun i m => m.recognized = (i.visitorId = "1234567890")

def FormatMessageContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (m.recognized = true → o.recognized = true ∧ o.message = "") ∧
                     (m.recognized = false → o.recognized = false ∧ o.message = "Visitor not recognized")

theorem po1 : Contract.Compatible RecognizeVisitorContract FormatMessageContract := by
  discharge_po1 [RecognizeVisitorContract, FormatMessageContract, Spec]

theorem po2 : Contract.Refines (RecognizeVisitorContract.seq FormatMessageContract) Spec := by
  discharge_po2 [RecognizeVisitorContract, FormatMessageContract, Spec]

-- L2 RecognizeVisitorContract (success=True)

def RecognizeVisitorContractImpl (x : Input) : Mid :=
  { recognized := x.visitorId = "1234567890" }

theorem RecognizeVisitorContractImpl_ok : RecognizeVisitorContract.Satisfies RecognizeVisitorContractImpl := by
  discharge_po3 [RecognizeVisitorContract, RecognizeVisitorContractImpl]

-- L2 FormatMessageContract (success=True)

def FormatMessageContractImpl (x : Mid) : Output :=
  { recognized := if x.recognized = true then true else if x.recognized = false then false else false,
    message := if x.recognized = true then "" else if x.recognized = false then "Visitor not recognized" else "Visitor not recognized" }

theorem FormatMessageContractImpl_ok : FormatMessageContract.Satisfies FormatMessageContractImpl := by
  discharge_po3 [FormatMessageContract, FormatMessageContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (FormatMessageContractImpl ∘ RecognizeVisitorContractImpl) :=
  Contract.system_sound po1 po2 RecognizeVisitorContractImpl_ok FormatMessageContractImpl_ok
