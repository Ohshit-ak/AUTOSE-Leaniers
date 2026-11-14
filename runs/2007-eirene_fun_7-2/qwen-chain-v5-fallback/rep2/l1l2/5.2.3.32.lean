import ContractForge
open ContractForge

-- 5.2.3.32: 5.2.3.32 Where a change of train number is required during the course of a trains journey, it shall be possible for the driver to initiate the change or override the automatic change. This shall be carried out by entering the train number (option 1 in 5.2.3.26). (M)

-- L0 spec

structure Input where
  currentTrainNumber : String
  newTrainNumber     : String
  deriving DecidableEq, Repr

structure Output where
  currentTrainNumber : String
  newTrainNumber     : String
  accepted           : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.currentTrainNumber ≠ "" ∧ i.newTrainNumber ≠ ""
  post := fun i o => (o.accepted = true ↔
    (i.currentTrainNumber ≠ i.newTrainNumber) ∧
    (o.currentTrainNumber = i.currentTrainNumber ∧ o.newTrainNumber = i.newTrainNumber)) ∧
    (o.accepted = false ↔
    (i.currentTrainNumber = i.newTrainNumber) ∧
    (o.currentTrainNumber = i.currentTrainNumber ∧ o.newTrainNumber = i.newTrainNumber))

example : Spec.pre { currentTrainNumber := "1234", newTrainNumber := "5678" } ∧
          Spec.post { currentTrainNumber := "1234", newTrainNumber := "5678" }
                    { currentTrainNumber := "1234", newTrainNumber := "5678", accepted := true } := by
  unfold Spec; decide

example : Spec.pre { currentTrainNumber := "1234", newTrainNumber := "1234" } ∧
          Spec.post { currentTrainNumber := "1234", newTrainNumber := "1234" }
                    { currentTrainNumber := "1234", newTrainNumber := "1234", accepted := false } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  currentTrainNumber : String
  newTrainNumber     : String
  accepted           : Bool
  deriving DecidableEq, Repr

def ComputeMidContract : Contract Input Mid where
  pre  := fun i => i.currentTrainNumber ≠ "" ∧ i.newTrainNumber ≠ ""
  post := fun i m => m.currentTrainNumber = i.currentTrainNumber ∧
                     m.newTrainNumber = i.newTrainNumber ∧
                     m.accepted = (i.currentTrainNumber ≠ i.newTrainNumber)

def FinalizeContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.currentTrainNumber = m.currentTrainNumber ∧
                     o.newTrainNumber = m.newTrainNumber ∧
                     (o.accepted = true ↔ m.accepted) ∧
                     (o.accepted = false ↔ m.accepted)

theorem po1 : Contract.Compatible ComputeMidContract FinalizeContract := by
  discharge_po1 [ComputeMidContract, FinalizeContract, Spec]

theorem po2 : Contract.Refines (ComputeMidContract.seq FinalizeContract) Spec := by
  discharge_po2 [ComputeMidContract, FinalizeContract, Spec]

-- L2 ComputeMidContract (success=True)

def ComputeMidContractImpl (x : Input) : Mid :=
  { currentTrainNumber := x.currentTrainNumber,
    newTrainNumber := x.newTrainNumber,
    accepted := x.currentTrainNumber ≠ x.newTrainNumber }

theorem ComputeMidContractImpl_ok : ComputeMidContract.Satisfies ComputeMidContractImpl := by
  discharge_po3 [ComputeMidContract, ComputeMidContractImpl]

-- L2 FinalizeContract (success=False)

def FinalizeContractImpl (x : Mid) : Output :=
  { currentTrainNumber := x.currentTrainNumber,
    newTrainNumber := x.newTrainNumber,
    accepted := decide (x.accepted) }
