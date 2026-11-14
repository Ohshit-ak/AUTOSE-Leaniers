import ContractForge
open ContractForge

-- 4.3.2.1a: Based on all relevant data, the ETCS shall calculate an emergency braking curve and a service braking curve
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  speedProfile : List Nat
  emergencyBrakeThreshold : Nat
  serviceBrakeThreshold : Nat
  deriving DecidableEq, Repr

structure Output where
  emergencyBrakingCurve : List Nat
  serviceBrakingCurve : List Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.speedProfile.Nodup ∧
                 0 < i.emergencyBrakeThreshold ∧
                 0 < i.serviceBrakeThreshold
  post := fun i o => o.emergencyBrakingCurve.length = i.speedProfile.length ∧
                     o.serviceBrakingCurve.length = i.speedProfile.length ∧
                     ∀ n ∈ i.speedProfile, o.emergencyBrakingCurve[n] ≤ i.emergencyBrakeThreshold ∧
                     ∀ n ∈ i.speedProfile, o.serviceBrakingCurve[n] ≤ i.serviceBrakeThreshold

example : Spec.pre { speedProfile := [10, 20, 30], emergencyBrakeThreshold := 50, serviceBrakeThreshold := 40 } ∧
          Spec.post { speedProfile := [10, 20, 30], emergencyBrakeThreshold := 50, serviceBrakeThreshold := 40 }
                    { emergencyBrakingCurve := [10, 20, 30], serviceBrakingCurve := [10, 20, 30] } := by
  unfold Spec; decide
