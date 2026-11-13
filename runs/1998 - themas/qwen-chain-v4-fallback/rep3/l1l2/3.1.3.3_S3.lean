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
  in_range : Bool
  error_message : String
  deriving DecidableEq, Repr

def ValidateTemperatureContract : Contract Input Mid where
  pre  := fun i => i.temperature < 10000 && i.valid_min < 10000 && i.valid_max < 10000
  post := fun i m => m.in_range = (i.temperature ≥ i.valid_min ∧ i.temperature ≤ i.valid_max) ∧
                     m.error_message = ""

def HandleErrorContract : Contract Mid Output where
  pre  := fun m => True
  post := fun m o => o.valid = false ∧ o.error_message ≠ "" ∧
                     o.error_message = m.error_message ∧
                     (o.valid = true ↔ m.in_range)



theorem po1 : Contract.Compatible ValidateTemperatureContract HandleErrorContract := by
  discharge_po1 [ValidateTemperatureContract, HandleErrorContract, Spec]

theorem po2 : Contract.Refines (ValidateTemperatureContract.seq HandleErrorContract) Spec := by
  discharge_po2 [ValidateTemperatureContract, HandleErrorContract, Spec]

-- L2 ValidateTemperatureContract (success=True)

def ValidateTemperatureContractImpl (x : Input) : Mid :=
  { in_range := decide (x.temperature ≥ x.valid_min ∧ x.temperature ≤ x.valid_max),
    error_message := "" }

theorem ValidateTemperatureContractImpl_ok : ValidateTemperatureContract.Satisfies ValidateTemperatureContractImpl := by
  discharge_po3 [ValidateTemperatureContract, ValidateTemperatureContractImpl]

-- L2 HandleErrorContract (success=False)

def HandleErrorContractImpl (x : Mid) : Output :=
  { valid := false,
    error_message := x.error_message }
