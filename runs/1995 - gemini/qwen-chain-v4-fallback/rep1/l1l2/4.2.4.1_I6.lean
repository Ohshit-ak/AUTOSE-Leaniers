import ContractForge
open ContractForge

-- 4.2.4.1/I6: Logging System logging information should include all important events, properly timestamped and indexed. The goal is to be able to recreate the steps in a observation from the system logs.

-- L0 spec

structure LogEntry where
  timestamp : Nat  -- Unix timestamp in seconds
  event     : String
  deriving DecidableEq, Repr

structure Input where
  logs : List LogEntry
  deriving DecidableEq, Repr

structure Output where
  logs : List LogEntry
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.logs.length > 0
  post := fun i o => o.logs = i.logs ∧
                     o.logs.all (fun le => 0 < le.timestamp) ∧
                     o.logs.all (fun le => le.event ≠ "")

example : Spec.pre { logs := [{ timestamp := 1633072800, event := "login" },
                               { timestamp := 1633072805, event := "logout" }] } ∧
          Spec.post { logs := [{ timestamp := 1633072800, event := "login" },
                                { timestamp := 1633072805, event := "logout" }] }
                    { logs := [{ timestamp := 1633072800, event := "login" },
                               { timestamp := 1633072805, event := "logout" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { logs := (x.logs.filter (fun le => 0 < le.timestamp)).map (fun le => LogEntry.mk le.timestamp le.event) }
