import ContractForge
open ContractForge

-- 3./I5: The VSP will send the collected claim forms monthly and send it to MSIU field office.

-- L0 spec

structure ClaimForm where
  formNumber : Nat
  date       : String
  deriving DecidableEq, Repr

structure Input where
  forms : List ClaimForm
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  message  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.forms.Nodup
  post := fun i o => (o.accepted = true ↔ i.forms.length > 0) ∧
                     (o.accepted = false → o.message = "No claim forms to process.")

example : Spec.pre { forms := [{ formNumber := 1, date := "2023-10-01" }] } ∧
          Spec.post { forms := [{ formNumber := 1, date := "2023-10-01" }] }
                    { accepted := true, message := "" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  hasForms : Bool
  deriving DecidableEq, Repr

def CheckFormsContract : Contract Input Mid where
  pre  := fun i => i.forms.Nodup
  post := fun i m => m.hasForms = true ∧ m.hasForms ↔ i.forms.length > 0

def GenerateOutputContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.accepted = true ↔ m.hasForms) ∧
                     (o.accepted = false → o.message = "No claim forms to process.")

theorem po1 : Contract.Compatible CheckFormsContract GenerateOutputContract := by
  discharge_po1 [CheckFormsContract, GenerateOutputContract, Spec]

theorem po2 : Contract.Refines (CheckFormsContract.seq GenerateOutputContract) Spec := by
  discharge_po2 [CheckFormsContract, GenerateOutputContract, Spec]

-- L2 CheckFormsContract (success=True)

def CheckFormsContractImpl (x : Input) : Mid :=
  { hasForms := x.forms.length > 0 }

theorem CheckFormsContractImpl_ok : CheckFormsContract.Satisfies CheckFormsContractImpl := by
  discharge_po3 [CheckFormsContract, CheckFormsContractImpl]

-- L2 GenerateOutputContract (success=True)

def GenerateOutputContractImpl (x : Mid) : Output :=
  { accepted := decide (x.hasForms),
    message := if x.hasForms then "" else "No claim forms to process." }

theorem GenerateOutputContractImpl_ok : GenerateOutputContract.Satisfies GenerateOutputContractImpl := by
  discharge_po3 [GenerateOutputContract, GenerateOutputContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (GenerateOutputContractImpl ∘ CheckFormsContractImpl) :=
  Contract.system_sound po1 po2 CheckFormsContractImpl_ok GenerateOutputContractImpl_ok
