import ContractForge
open ContractForge

-- 7.2.3.9: 7.2.3.9 When the mobile changes network automatically, a visual and audible indication shall be given. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  networkChange : Bool
  visualIndication : Bool
  audibleIndication : Bool
  deriving DecidableEq, Repr

structure Output where
  networkChange : Bool
  visualIndication : Bool
  audibleIndication : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.networkChange = true
  post := fun i o => (o.visualIndication = true ∧ o.audibleIndication = true) ↔ i.networkChange = true

example : Spec.pre { networkChange := true, visualIndication := false, audibleIndication := false } ∧
          Spec.post { networkChange := true, visualIndication := false, audibleIndication := false }
                    { networkChange := true, visualIndication := true, audibleIndication := true } := by
  unfold Spec; decide
