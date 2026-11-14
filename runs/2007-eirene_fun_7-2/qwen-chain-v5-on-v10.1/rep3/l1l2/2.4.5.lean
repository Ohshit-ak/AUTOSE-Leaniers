import ContractForge
open ContractForge

-- 2.4.5: 2.4.5 The network shall provide a mechanism whereby calls may be assigned one of a number of different priority levels. (M)

-- L0 spec

structure Call where
  priority : Nat
  deriving DecidableEq, Repr

structure Input where
  calls : List Call
  deriving DecidableEq, Repr

structure Output where
  calls : List Call
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.calls.Nodup
  post := fun i o => o.calls = i.calls ∧
                     (∀ c ∈ o.calls, 0 ≤ c.priority ∧ c.priority ≤ 10)

example : Spec.pre { calls := [{ priority := 5 }, { priority := 7 }] } ∧
          Spec.post { calls := [{ priority := 5 }, { priority := 7 }] }
                    { calls := [{ priority := 5 }, { priority := 7 }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { calls := x.calls.filter fun c => 0 ≤ c.priority ∧ c.priority ≤ 10 }
