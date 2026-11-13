import ContractForge
open ContractForge

-- 3.4.2.9/S2: Specifically, contracting authorities must provide a way to receive electronic tenders and ensure those electronic tenders are not accessed until the prescribed time for opening them.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  tenders : List String
  openingTime : Nat
  currentTimestamp : Nat
  deriving DecidableEq, Repr

structure Output where
  tenders : List String
  accepted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.currentTimestamp < i.openingTime
  post := fun i o => (o.accepted = true ↔
    i.currentTimestamp < i.openingTime ∧
    ∀ t ∈ i.tenders, o.tenders.contains t) ∧
    (o.accepted = false → o.tenders = [])

example : Spec.pre { tenders := ["t1", "t2"], openingTime := 100, currentTimestamp := 50 } ∧
          Spec.post { tenders := ["t1", "t2"], openingTime := 100, currentTimestamp := 50 }
                    { accepted := true, tenders := ["t1", "t2"] } := by
  unfold Spec; decide
