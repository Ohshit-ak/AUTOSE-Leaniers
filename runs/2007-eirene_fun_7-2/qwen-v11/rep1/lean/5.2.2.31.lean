import ContractForge
open ContractForge

-- 5.2.2.31: 5.2.2.31 The lead driver shall be able to terminate the entire call. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Call where
  leadDriver : Bool
  active     : Bool
  deriving DecidableEq, Repr

structure Input where
  leadDriver : Bool
  active     : Bool
  terminating : Bool
  deriving DecidableEq, Repr

structure Output where
  leadDriver : Bool
  active     : Bool
  terminating : Bool
  callTerminated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.leadDriver = true ∧ i.active = true
  post := fun i o => (o.callTerminated = true ↔ o.terminating = true) ∧
                     (o.callTerminated = true → o.active = false) ∧
                     o.leadDriver = i.leadDriver ∧
                     o.active = false ∧
                     o.terminating = i.terminating

example : Spec.pre { leadDriver := true, active := true, terminating := true } ∧
          Spec.post { leadDriver := true, active := true, terminating := true }
                     { leadDriver := true, active := false, terminating := true, callTerminated := true } := by
  unfold Spec; decide
