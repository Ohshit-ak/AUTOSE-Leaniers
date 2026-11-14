import ContractForge
open ContractForge

-- 3.1.5.1.3/S3: When a request to turn on a heating or cooling unit is received, the system shall determine if the request can be honored.

-- L0 spec

structure Input where
  unitId : Nat
  request : Bool
  status : Bool
  deriving DecidableEq, Repr

structure Output where
  canHonor : Bool
  newStatus : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.request = true
  post := fun i o => (o.canHonor = true ↔ i.status = false) ∧
                     (o.canHonor = true → o.newStatus = true) ∧
                     (o.canHonor = false → o.newStatus = i.status)

example : Spec.pre { unitId := 1, request := true, status := false } ∧
          Spec.post { unitId := 1, request := true, status := false }
                    { canHonor := true, newStatus := true } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  canHonor : Bool
  status : Bool
  deriving DecidableEq, Repr

def ComputeCanHonorContract : Contract Input Mid where
  pre  := fun i => i.request = true
  post := fun i m => (m.canHonor = true ↔ i.status = false) ∧ m.status = i.status

def UpdateStatusContract : Contract Mid Output where
  pre  := fun m => True
  post := fun m o => o.canHonor = m.canHonor ∧
                     (o.canHonor = true → o.newStatus = true) ∧
                     (o.canHonor = false → o.newStatus = m.status)

theorem po1 : Contract.Compatible ComputeCanHonorContract UpdateStatusContract := by
  discharge_po1 [ComputeCanHonorContract, UpdateStatusContract, Spec]

theorem po2 : Contract.Refines (ComputeCanHonorContract.seq UpdateStatusContract) Spec := by
  discharge_po2 [ComputeCanHonorContract, UpdateStatusContract, Spec]

-- L2 ComputeCanHonorContract (success=True)

def ComputeCanHonorContractImpl (x : Input) : Mid :=
  { canHonor := decide (x.status = false),
    status := x.status }

theorem ComputeCanHonorContractImpl_ok : ComputeCanHonorContract.Satisfies ComputeCanHonorContractImpl := by
  discharge_po3 [ComputeCanHonorContract, ComputeCanHonorContractImpl]

-- L2 UpdateStatusContract (success=True)

def UpdateStatusContractImpl (x : Mid) : Output :=
  { canHonor := x.canHonor,
    newStatus := if x.canHonor then true else x.status }

theorem UpdateStatusContractImpl_ok : UpdateStatusContract.Satisfies UpdateStatusContractImpl := by
  discharge_po3 [UpdateStatusContract, UpdateStatusContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (UpdateStatusContractImpl ∘ ComputeCanHonorContractImpl) :=
  Contract.system_sound po1 po2 ComputeCanHonorContractImpl_ok UpdateStatusContractImpl_ok
