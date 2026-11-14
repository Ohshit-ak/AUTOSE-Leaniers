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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  accessed : Bool
  tender   : Option String
  deriving DecidableEq, Repr

def ComputeAccessContract : Contract Input Mid where
  pre  := fun i => i.tenders.Nodup
  post := fun i m => m.accessed = false ↔ i.prescribedTime = 0 ∧
                     (m.accessed = true ↔ i.prescribedTime = 0 ∧
                      m.tender ∈ i.tenders)

def ApplyAccessContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.accessed = m.accessed ∧
                     o.tenders = m.tender.nel.dflt.get_or_else []
