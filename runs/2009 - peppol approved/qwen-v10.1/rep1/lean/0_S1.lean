import ContractForge
open ContractForge

-- 0/S1: This preface provides a short overview about the comments received from the EC and other sources and how these comments and remarks will be taken into consideration in future/ongoing work.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  commentsReceived : List String
  deriving DecidableEq, Repr

structure Output where
  remarksConsidered : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.commentsReceived ≠ []
  post := fun i o => o.remarksConsidered = i.commentsReceived

example : Spec.pre { commentsReceived := ["EC comment 1", "EC comment 2"] } ∧
          Spec.post { commentsReceived := ["EC comment 1", "EC comment 2"] }
                    { remarksConsidered := ["EC comment 1", "EC comment 2"] } := by
  unfold Spec; decide
