import ContractForge
open ContractForge

-- 4.2.4.2/I3: Recovery In addition to start-up procedures, there must be well-defined recovery procedures for any subsystem that has become inoperative. Command retries must be included in the system for most common timeouts or noresponse conditions. These retries should occur automatically in the command handling to avoid unnecessary error conditions.

-- L0 spec

structure Input where
  retries : Nat
  timeout : Nat
  deriving DecidableEq, Repr

structure Output where
  retries : Nat
  timeout : Nat
  succeeded : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.retries ∧ 0 < i.timeout
  post := fun i o => (o.succeeded = true ↔
    (o.retries = i.retries - 1 ∧ o.timeout = i.timeout) ∨
    (o.retries = i.retries ∧ o.timeout = i.timeout - 1)) ∧
    (o.succeeded = false → o.retries = i.retries ∧ o.timeout = i.timeout)

example : Spec.pre { retries := 3, timeout := 5 } ∧ Spec.post { retries := 3, timeout := 5 } { retries := 2, timeout := 5, succeeded := true } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  retries : Nat
  timeout : Nat
  deriving DecidableEq, Repr

def ComputeIntermediateContract : Contract Input Mid where
  pre  := fun i => 0 < i.retries ∧ 0 < i.timeout
  post := fun i m => (m.retries = i.retries - 1 ∧ m.timeout = i.timeout) ∨
                     (m.retries = i.retries ∧ m.timeout = i.timeout - 1)

def FinalizeContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.succeeded = true ↔
    (o.retries = m.retries - 1 ∧ o.timeout = m.timeout) ∨
    (o.retries = m.retries ∧ o.timeout = m.timeout - 1)) ∧
    (o.succeeded = false → o.retries = m.retries ∧ o.timeout = m.timeout)
