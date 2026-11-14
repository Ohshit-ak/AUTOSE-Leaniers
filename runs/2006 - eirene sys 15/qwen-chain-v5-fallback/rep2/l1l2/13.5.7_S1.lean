import ContractForge
open ContractForge

-- 13.5.7/S1: Confirmation messages shall be sent to a confirmation centre using a defined short code (see table 9-10), which shall be associated with the GSM network.

-- L0 spec

structure Input where
  shortCode : String
  deriving DecidableEq, Repr

structure Output where
  confirmed : Bool
  message   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.shortCode.length = 4 ∧
                  i.shortCode.toList.all Char.isDigit = true
  post := fun i o => (o.confirmed = true ↔ i.shortCode = "1122") ∧
                     (o.confirmed = false → o.message = "Invalid short code")

example : Spec.pre { shortCode := "1122" } ∧
          Spec.post { shortCode := "1122" }
                    { confirmed := true, message := "" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  confirmed : Bool
  deriving DecidableEq, Repr

def CheckShortCodeContract : Contract Input Mid where
  pre  := fun i => i.shortCode.length = 4 ∧
                  i.shortCode.toList.all Char.isDigit = true
  post := fun i m => m.confirmed = true ↔ i.shortCode = "1122"

def FormatOutputContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.confirmed = m.confirmed) ∧
                     (o.confirmed = false → o.message = "Invalid short code")

theorem po1 : Contract.Compatible CheckShortCodeContract FormatOutputContract := by
  discharge_po1 [CheckShortCodeContract, FormatOutputContract, Spec]

theorem po2 : Contract.Refines (CheckShortCodeContract.seq FormatOutputContract) Spec := by
  discharge_po2 [CheckShortCodeContract, FormatOutputContract, Spec]

-- L2 CheckShortCodeContract (success=True)

def CheckShortCodeContractImpl (x : Input) : Mid :=
  { confirmed := decide (x.shortCode = "1122") }

theorem CheckShortCodeContractImpl_ok : CheckShortCodeContract.Satisfies CheckShortCodeContractImpl := by
  discharge_po3 [CheckShortCodeContract, CheckShortCodeContractImpl]

-- L2 FormatOutputContract (success=True)

def FormatOutputContractImpl (x : Mid) : Output :=
  { confirmed := x.confirmed,
    message := if x.confirmed = false then "Invalid short code" else "" }

theorem FormatOutputContractImpl_ok : FormatOutputContract.Satisfies FormatOutputContractImpl := by
  discharge_po3 [FormatOutputContract, FormatOutputContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (FormatOutputContractImpl ∘ CheckShortCodeContractImpl) :=
  Contract.system_sound po1 po2 CheckShortCodeContractImpl_ok FormatOutputContractImpl_ok
