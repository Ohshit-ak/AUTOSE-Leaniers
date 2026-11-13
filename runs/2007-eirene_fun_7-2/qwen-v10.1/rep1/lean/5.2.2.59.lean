import ContractForge
open ContractForge

-- 5.2.2.59: 5.2.2.59 Automatic confirmation of receipt of Railway emergency calls will be used to provide a means of determining which trains have received a Railway emergency call (see section 13). (I) Terminate calls
-- compiles: False · rejects_bad_example: None · checked: False

structure Call where
  trainId : Nat
  isEmergency : Bool
  isConfirmed : Bool
  deriving DecidableEq, Repr

structure Input where
  calls : List Call
  deriving DecidableEq, Repr

structure Output where
  confirmed : List Call
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.calls.length > 0
  post := fun i o => o.confirmed.length = i.calls.filter (fun c => c.isEmergency).length ∧
                     ∀ c ∈ o.confirmed, c.isEmergency = true ∧ c.isConfirmed = true

example : Spec.pre { calls := [{ trainId := 1, isEmergency := true, isConfirmed := false },
                                { trainId := 2, isEmergency := false, isConfirmed := false }] } ∧
          Spec.post { calls := [{ trainId := 1, isEmergency := true, isConfirmed := false },
                                 { trainId := 2, isEmergency := false, isConfirmed := false }] }
                    { confirmed := [{ trainId := 1, isEmergency := true, isConfirmed := true }] } := by
  unfold Spec; decide
