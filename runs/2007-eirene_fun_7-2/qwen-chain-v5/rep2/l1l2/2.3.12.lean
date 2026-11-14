import ContractForge
open ContractForge

-- 2.3.12: 2.3.12 Where fax functionality is provided, it shall be possible to interrupt the fax to make or receive a high priority voice or data call. (M) Train control applications

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { faxActive := false, calls := x.calls.filter (fun c => c.priority > 0) }
