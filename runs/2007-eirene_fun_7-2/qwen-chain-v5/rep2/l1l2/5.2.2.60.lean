import ContractForge
open ContractForge

-- 5.2.2.60: 5.2.2.60 The Cab radio shall provide a means for the driver to terminate calls which he is authorised to terminate (ie all calls except Railway emergency calls not initiated by the driver and shunting group calls). (M)

-- L0 spec

structure Call where
  initiatedByDriver : Bool
  isEmergency      : Bool
  deriving DecidableEq, Repr

structure Input where
  calls : List Call
  deriving DecidableEq, Repr

structure Output where
  terminatedCalls : List Call
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.calls.Nodup
  post := fun i o => 
    (∀ c ∈ o.terminatedCalls, 
     c.initiatedByDriver = true ∧ ¬c.isEmergency) ∧
    (o.terminatedCalls.length ≤ i.calls.length) ∧
    (o.terminatedCalls = [] ↔ 
     ∀ c ∈ i.calls, c.initiatedByDriver = false ∨ c.isEmergency)

example : Spec.pre { calls := [{ initiatedByDriver := true, isEmergency := false },
                                { initiatedByDriver := false, isEmergency := false }] } ∧
          Spec.post { calls := [{ initiatedByDriver := true, isEmergency := false },
                                 { initiatedByDriver := false, isEmergency := false }] }
                    { terminatedCalls := [{ initiatedByDriver := true, isEmergency := false }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { terminatedCalls := 
    if ∀ c ∈ x.calls, c.initiatedByDriver = false ∨ c.isEmergency then
      []
    else
      (x.calls.filter (fun c => decide (c.initiatedByDriver = true ∧ ¬c.isEmergency))).take x.calls.length }
