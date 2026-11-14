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

def ConfirmShortCodeContract : Contract Input Mid where
  pre  := fun i => i.shortCode.length = 4 ∧
                  i.shortCode.toList.all Char.isDigit = true
  post := fun i m => m.confirmed = true ↔ i.shortCode = "1122"

def FormatMessageContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (m.confirmed = true → o.confirmed = true ∧ o.message = "") ∧
                     (m.confirmed = false → o.confirmed = false ∧ o.message = "Invalid short code")

theorem po1 : Contract.Compatible ConfirmShortCodeContract FormatMessageContract := by
  discharge_po1 [ConfirmShortCodeContract, FormatMessageContract, Spec]

theorem po2 : Contract.Refines (ConfirmShortCodeContract.seq FormatMessageContract) Spec := by
  discharge_po2 [ConfirmShortCodeContract, FormatMessageContract, Spec]

-- L2 ConfirmShortCodeContract (success=True)

def ConfirmShortCodeContractImpl (x : Input) : Mid :=
  { confirmed := decide (x.shortCode = "1122") }

theorem ConfirmShortCodeContractImpl_ok : ConfirmShortCodeContract.Satisfies ConfirmShortCodeContractImpl := by
  discharge_po3 [ConfirmShortCodeContract, ConfirmShortCodeContractImpl]

-- L2 FormatMessageContract (success=True)

def FormatMessageContractImpl (x : Mid) : Output :=
  { confirmed := if x.confirmed = true then true else if x.confirmed = false then false else false,
    message := if x.confirmed = true then "" else if x.confirmed = false then "Invalid short code" else "Invalid short code" }

theorem FormatMessageContractImpl_ok : FormatMessageContract.Satisfies FormatMessageContractImpl := by
  discharge_po3 [FormatMessageContract, FormatMessageContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (FormatMessageContractImpl ∘ ConfirmShortCodeContractImpl) :=
  Contract.system_sound po1 po2 ConfirmShortCodeContractImpl_ok FormatMessageContractImpl_ok
