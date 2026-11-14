import ContractForge
open ContractForge

-- 1.1/S4: When a contracting authority publishes a contract notice, it shall include the selection, qualification and nonexclusion criteria.

-- L0 spec

structure Input where
  criteria : List String
  deriving DecidableEq, Repr

structure Output where
  included : Bool
  notice : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.criteria ≠ []
  post := fun i o => (o.included = true ↔
    ∃ c ∈ i.criteria, c ≠ "") ∧
    (o.included = false → o.notice = "Contract Notice without selection criteria")

example : Spec.pre { criteria := ["Experience in public procurement", "Financial stability"] } ∧
          Spec.post { criteria := ["Experience in public procurement", "Financial stability"] }
                    { included := true, notice := "Contract Notice with selection criteria" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  notice : String
  deriving DecidableEq, Repr

def ComputeNoticeContract : Contract Input Mid where
  pre  := fun i => i.criteria ≠ []
  post := fun i m => (m.notice = "Contract Notice with selection criteria" ↔
    ∃ c ∈ i.criteria, c ≠ "") ∧
    (m.notice = "Contract Notice without selection criteria" ↔
    i.criteria = [])

def DetermineIncludedContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.included = true ↔ m.notice = "Contract Notice with selection criteria") ∧
                     (o.included = false → o.notice = "Contract Notice without selection criteria")

theorem po1 : Contract.Compatible ComputeNoticeContract DetermineIncludedContract := by
  discharge_po1 [ComputeNoticeContract, DetermineIncludedContract, Spec]

theorem po2 : Contract.Refines (ComputeNoticeContract.seq DetermineIncludedContract) Spec := by
  discharge_po2 [ComputeNoticeContract, DetermineIncludedContract, Spec]

-- L2 ComputeNoticeContract (success=False)

def ComputeNoticeContractImpl (x : Input) : Mid :=
  { notice := if ∃ c ∈ x.criteria, c ≠ "" then "Contract Notice with selection criteria" else if x.criteria = [] then "Contract Notice without selection criteria" else "Contract Notice with selection criteria" }

-- L2 DetermineIncludedContract (success=True)

def DetermineIncludedContractImpl (x : Mid) : Output :=
  { included := decide (x.notice = "Contract Notice with selection criteria"),
    notice := if x.notice = "Contract Notice with selection criteria" then "Contract Notice with selection criteria" else "Contract Notice without selection criteria" }

theorem DetermineIncludedContractImpl_ok : DetermineIncludedContract.Satisfies DetermineIncludedContractImpl := by
  discharge_po3 [DetermineIncludedContract, DetermineIncludedContractImpl]
