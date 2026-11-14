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
  included : Bool
  deriving DecidableEq, Repr

def ComputeIncludedContract : Contract Input Mid where
  pre  := fun i => i.criteria ≠ []
  post := fun i m => m.included = true ↔
    ∃ c ∈ i.criteria, c ≠ ""

def GenerateNoticeContract : Contract Mid Output where
  pre  := fun m => True
  post := fun m o => o.included = m.included ∧
    (m.included = false → o.notice = "Contract Notice without selection criteria")



theorem po1 : Contract.Compatible ComputeIncludedContract GenerateNoticeContract := by
  discharge_po1 [ComputeIncludedContract, GenerateNoticeContract, Spec]

theorem po2 : Contract.Refines (ComputeIncludedContract.seq GenerateNoticeContract) Spec := by
  discharge_po2 [ComputeIncludedContract, GenerateNoticeContract, Spec]

-- L2 ComputeIncludedContract (success=True)

def ComputeIncludedContractImpl (x : Input) : Mid :=
  { included := decide (∃ c ∈ x.criteria, c ≠ "") }

theorem ComputeIncludedContractImpl_ok : ComputeIncludedContract.Satisfies ComputeIncludedContractImpl := by
  discharge_po3 [ComputeIncludedContract, ComputeIncludedContractImpl]

-- L2 GenerateNoticeContract (success=True)

def GenerateNoticeContractImpl (x : Mid) : Output :=
  { included := x.included,
    notice := if x.included = false then "Contract Notice without selection criteria" else "Contract Notice with selection criteria" }

theorem GenerateNoticeContractImpl_ok : GenerateNoticeContract.Satisfies GenerateNoticeContractImpl := by
  discharge_po3 [GenerateNoticeContract, GenerateNoticeContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (GenerateNoticeContractImpl ∘ ComputeIncludedContractImpl) :=
  Contract.system_sound po1 po2 ComputeIncludedContractImpl_ok GenerateNoticeContractImpl_ok
