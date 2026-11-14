import ContractForge
open ContractForge

-- 3.8.1/S1: Using risk assessment procedures defined in DoD 5200.28(D), a risk index and the minimum security requirements for TCS shall be determined. [SSS363] The inputs to this procedure are the clearance or authorization of the TCS users and the sensitivities of the data that the TCS processes, stores or transfers.

-- L0 spec

structure Input where
  clearance : String
  sensitivities : List String
  deriving DecidableEq, Repr

structure Output where
  riskIndex : Nat
  securityRequirements : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.clearance ≠ "" ∧ i.sensitivities.Nodup
  post := fun i o => o.riskIndex = 1 + i.sensitivities.length ∧
                     o.securityRequirements.length ≥ 3 ∧
                     (∀ req ∈ o.securityRequirements, req ≠ "" ∧ req ∈ ["Confidential", "Secret", "Top Secret"])

example : Spec.pre { clearance := "Top Secret", sensitivities := ["Confidential", "Secret"] } ∧
          Spec.post { clearance := "Top Secret", sensitivities := ["Confidential", "Secret"] }
                    { riskIndex := 3, securityRequirements := ["Confidential", "Secret", "Top Secret"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { riskIndex := 1 + x.sensitivities.length,
    securityRequirements := 
      x.sensitivities.filter (fun req => req ≠ "" ∧ req ∈ ["Confidential", "Secret", "Top Secret"])
      |>.take 3 |>.map (fun req => req)
      |>.ensureLength
  }

def ensureLength (l : List String) : List String :=
  if l.length < 3 then l ++ (List.repeat "" (3 - l.length)) else l
