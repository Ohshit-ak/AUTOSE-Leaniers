import ContractForge
open ContractForge

-- 4/performance-and-scalability/R4: The System must be able to retrieve and display within 20 seconds the case which has not been accessed within the previous 2 months, regardless of storage capacity or number of cases in the system. This requirement is intended to allow for cases where cases used infrequently are stored on slower media than more active records.

-- L0 spec

structure Input where
  cases : List String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  caseId        : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cases.Nodup
  post := fun i o => o.elapsedMicros ≤ 20000000 ∧
                     (o.caseId = i.cases.getLastD "C0" ∧
                      o.elapsedMicros > 0)

example : Spec.pre { cases := ["C1", "C2", "C3"], elapsedMicros := 15000000 } ∧
          Spec.post { cases := ["C1", "C2", "C3"], elapsedMicros := 15000000 }
                    { elapsedMicros := 15000000, caseId := "C3" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { elapsedMicros := min 20000000 (x.cases.size * 1000000),
    caseId := x.cases.getLastD "C0" }
