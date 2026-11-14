import ContractForge
open ContractForge

-- 4/system-availability/R4: The number of incidents of unplanned downtime for the System must not exceed <x> per <rolling three month period>.

-- L0 spec

structure Input where
  downtimeIncidents : Nat
  deriving DecidableEq, Repr

structure Output where
  downtimeIncidents : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.downtimeIncidents = i.downtimeIncidents ∧
                     (i.downtimeIncidents ≤ 3)

example : Spec.pre { downtimeIncidents := 2 } ∧
          Spec.post { downtimeIncidents := 2 }
                    { downtimeIncidents := 2 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { downtimeIncidents := if x.downtimeIncidents ≤ 3 then x.downtimeIncidents else 0 }
