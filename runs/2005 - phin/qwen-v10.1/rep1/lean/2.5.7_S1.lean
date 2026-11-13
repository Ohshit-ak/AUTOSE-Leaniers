import ContractForge
open ContractForge

-- 2.5.7/S1: Systems supporting OM must be able to exchange messages for confirmed, probable and suspect cases, and the other case classifications that are noted in the PHIN message implementation guide, with systems supporting surveillance, early event detection (EED), and other preparedness areas.
-- compiles: True · rejects_bad_example: None · checked: True

structure Case where
  classification : String
  details        : String
  deriving DecidableEq, Repr

structure Input where
  cases : List Case
  deriving DecidableEq, Repr

structure Output where
  cases : List Case
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cases.length > 0
  post := fun i o => o.cases.length = i.cases.length ∧
                     ∀ c ∈ i.cases, c ∈ o.cases ∧
                     (c.classification = "confirmed" ∨
                      c.classification = "probable" ∨
                      c.classification = "suspect" ∨
                      c.classification = "other" ∨
                      c.classification = "unclassified")

example : Spec.pre { cases := [{ classification := "confirmed", details := "details1" },
                               { classification := "probable", details := "details2" },
                               { classification := "suspect", details := "details3" },
                               { classification := "other", details := "details4" },
                               { classification := "unclassified", details := "details5" }] } ∧
          Spec.post { cases := [{ classification := "confirmed", details := "details1" },
                                 { classification := "probable", details := "details2" },
                                 { classification := "suspect", details := "details3" },
                                 { classification := "other", details := "details4" },
                                 { classification := "unclassified", details := "details5" }] }
                    { cases := [{ classification := "confirmed", details := "details1" },
                                { classification := "probable", details := "details2" },
                                { classification := "suspect", details := "details3" },
                                { classification := "other", details := "details4" },
                                { classification := "unclassified", details := "details5" }] } := by
  unfold Spec; decide
