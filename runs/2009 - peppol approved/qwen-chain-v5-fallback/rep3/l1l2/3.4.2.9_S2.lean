import ContractForge
open ContractForge

-- 3.4.2.9/S2: Specifically, contracting authorities must provide a way to receive electronic tenders and ensure those electronic tenders are not accessed until the prescribed time for opening them.

-- L0 spec

structure Input where
  tenders : List String
  prescribedTime : Nat
  deriving DecidableEq, Repr

structure Output where
  tenders : List String
  accessed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.tenders.Nodup
  post := fun i o => (o.accessed = false ↔ i.prescribedTime = 0) ∧
                     (o.accessed = true ↔ i.prescribedTime = 0 ∧
                     ∃ t ∈ i.tenders, t ∈ o.tenders)

example : Spec.pre { tenders := ["t1", "t2"], prescribedTime := 0 } ∧ Spec.post { tenders := ["t1", "t2"], prescribedTime := 0 } { tenders := [], accessed := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { tenders := x.tenders,
    accessed := decide (x.prescribedTime = 0 ∧ ∃ t ∈ x.tenders, t ∈ x.tenders) }
