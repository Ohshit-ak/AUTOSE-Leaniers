import ContractForge
open ContractForge

-- 2.3.12: 2.3.12 Where fax functionality is provided, it shall be possible to interrupt the fax to make or receive a high priority voice or data call. (M) Train control applications
-- compiles: True · rejects_bad_example: True · checked: True

structure Call where
  type    : String
  priority : Nat
  duration : Nat
  deriving DecidableEq, Repr

structure Input where
  faxActive : Bool
  calls     : List Call
  deriving DecidableEq, Repr

structure Output where
  faxActive : Bool
  calls     : List Call
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.faxActive = true ∧ i.calls.length > 0
  post := fun i o => (o.faxActive = false ∧ o.calls.length = i.calls.length ∧
                      ∃ c ∈ o.calls, c.priority > 0) ↔
                    (i.faxActive = true ∧ i.calls.length > 0 ∧
                     ∃ c ∈ i.calls, c.priority > 0)

example : Spec.pre { faxActive := true, calls := [{ type := "voice", priority := 1, duration := 10 },
                                                   { type := "data", priority := 2, duration := 20 }] } ∧
          Spec.post { faxActive := true, calls := [{ type := "voice", priority := 1, duration := 10 },
                                                    { type := "data", priority := 2, duration := 20 }] }
                    { faxActive := false, calls := [{ type := "voice", priority := 1, duration := 10 },
                                                    { type := "data", priority := 2, duration := 20 }] } := by
  unfold Spec; decide
