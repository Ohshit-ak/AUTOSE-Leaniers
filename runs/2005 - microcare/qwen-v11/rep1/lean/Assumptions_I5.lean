import ContractForge
open ContractForge

-- Assumptions/I5: System should calculate Claim Amount only based on treatment matrix
-- compiles: False · rejects_bad_example: None · checked: False

structure Treatment where
  code : String
  amount : Nat
  deriving DecidableEq, Repr

structure Input where
  treatments : List Treatment
  claim : String
  deriving DecidableEq, Repr

structure Output where
  amount : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.treatments.Nodup
  post := fun i o => o.amount = 
    i.treatments.filter (fun t => t.code ∈ i.claim).sum (fun t => t.amount)

example : Spec.pre { treatments := [{ code := "A1", amount := 500 },
                                     { code := "A2", amount := 300 }],
                     claim := "A1" } ∧
          Spec.post { treatments := [{ code := "A1", amount := 500 },
                                     { code := "A2", amount := 300 }],
                     claim := "A1" }
                    { amount := 500 } := by
  unfold Spec; decide
