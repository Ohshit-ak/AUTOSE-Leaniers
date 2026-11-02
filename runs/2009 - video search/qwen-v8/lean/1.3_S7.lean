import ContractForge
open ContractForge

-- 1.3/S7: The system will contain databases of the different websites that will be used within the search.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  websites : List String
  deriving DecidableEq, Repr

structure Output where
  databases : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.websites.Nodup
  post := fun i o => o.databases = i.websites

example : Spec.pre { websites := ["site1", "site2", "site3"] } ∧
          Spec.post { websites := ["site1", "site2", "site3"] }
                    { databases := ["site1", "site2", "site3"] } := by
  unfold Spec; decide
