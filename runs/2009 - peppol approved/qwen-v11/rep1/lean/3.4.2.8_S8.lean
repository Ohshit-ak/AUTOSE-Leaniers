import ContractForge
open ContractForge

-- 3.4.2.8/S8: Requirement The PEPPOL infrastructure SHOULD have the capability to submit a bid which contains a VCD.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  bid : String
  vcd : String
  deriving DecidableEq, Repr

structure Output where
  submitted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.submitted = true ↔
    (i.vcd.length > 0 ∧ i.bid.length > 0)

example : Spec.pre { bid := "BID123", vcd := "VCD456" } ∧
          Spec.post { bid := "BID123", vcd := "VCD456" }
                    { submitted := true } := by
  unfold Spec; decide
