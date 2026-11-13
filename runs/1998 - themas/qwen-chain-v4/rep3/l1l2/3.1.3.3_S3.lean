import ContractForge
open ContractForge

-- 3.1.3.3/S3: A current temperature value that is received from an individual thermostat shall be compared to the valid temperature range values.

-- L0 spec

structure Input where
  temperature : Nat
  valid_min   : Nat
  valid_max   : Nat
  deriving DecidableEq, Repr

structure Output where
  valid         : Bool
  error_message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.temperature < 10000 && i.valid_min < 10000 && i.valid_max < 10000
  post := fun i o => (o.valid = true ↔ i.temperature ≥ i.valid_min ∧ i.temperature ≤ i.valid_max) ∧
                     (o.valid = false → o.error_message ≠ "")

example : Spec.pre { temperature := 25, valid_min := 0, valid_max := 50 } ∧
          Spec.post { temperature := 25, valid_min := 0, valid_max := 50 }
                    { valid := true, error_message := "" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  temperature : Nat
  valid       : Bool
  deriving DecidableEq, Repr

def ComputeValidityContract : Contract Input Mid where
  pre  := fun i => i.temperature < 10000 && i.valid_min < 10000 && i.valid_max < 10000
  post := fun i m => m.valid = (i.temperature ≥ i.valid_min ∧ i.temperature ≤ i.valid_max)

def HandleErrorContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (m.valid = true → o.valid = true ∧ o.error_message = "") ∧
                     (m.valid = false → o.valid = false ∧ o.error_message ≠ "")

theorem po1 : Contract.Compatible ComputeValidityContract HandleErrorContract := by
  discharge_po1 [ComputeValidityContract, HandleErrorContract, Spec]

theorem po2 : Contract.Refines (ComputeValidityContract.seq HandleErrorContract) Spec := by
  discharge_po2 [ComputeValidityContract, HandleErrorContract, Spec]

-- L2 ComputeValidityContract (success=True)

def ComputeValidityContractImpl (x : Input) : Mid :=
  { temperature := x.temperature, valid := decide (x.temperature ≥ x.valid_min ∧ x.temperature ≤ x.valid_max) }

theorem ComputeValidityContractImpl_ok : ComputeValidityContract.Satisfies ComputeValidityContractImpl := by
  discharge_po3 [ComputeValidityContract, ComputeValidityContractImpl]

-- L2 HandleErrorContract (success=True)

def HandleErrorContractImpl (x : Mid) : Output :=
  { valid := x.valid,
    error_message := if x.valid then "" else "Invalid temperature" }

theorem HandleErrorContractImpl_ok : HandleErrorContract.Satisfies HandleErrorContractImpl := by
  discharge_po3 [HandleErrorContract, HandleErrorContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (HandleErrorContractImpl ∘ ComputeValidityContractImpl) :=
  Contract.system_sound po1 po2 ComputeValidityContractImpl_ok HandleErrorContractImpl_ok
