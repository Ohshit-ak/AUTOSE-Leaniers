import ContractForge
open ContractForge

-- Assumptions/I5: System should calculate Claim Amount only based on treatment matrix
-- compiles: True · rejects_bad_example: None · checked: False

structure Treatment where
  code : String
  amount : Nat
  deriving DecidableEq, Repr

structure Claim where
  treatments : List Treatment
  deriving DecidableEq, Repr

structure Input where
  treatments : List Treatment
  deriving DecidableEq, Repr

structure Output where
  claimAmount : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.treatments.Nodup
  post := fun i o => o.claimAmount = (i.treatments.map (fun t => t.amount)).sum

example : Spec.pre { treatments := [{ code := "T1", amount := 100 },
                                      { code := "T2", amount := 200 }] } ∧
          Spec.post { treatments := [{ code := "T1", amount := 100 },
                                      { code := "T2", amount := 200 }] }
                    { claimAmount := 300 } := by
  unfold Spec; decide
