import ContractForge
open ContractForge

-- 3.4.2/S7: In any case, remote operation must include remote monitoring from the Gemini 8m Telescopes base facilities, together with access tools for diagnostic and test use.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  remoteMonitoring : Bool
  accessTools      : Bool
  deriving DecidableEq, Repr

structure Output where
  remoteMonitoring : Bool
  accessTools      : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.remoteMonitoring = true ∧ i.accessTools = true
  post := fun i o => o.remoteMonitoring = true ∧
                     o.accessTools = true ∧
                     (o.remoteMonitoring = i.remoteMonitoring ↔
                      (i.remoteMonitoring = true ∧ i.accessTools = true)) ∧
                     (o.accessTools = i.accessTools ↔
                      (i.remoteMonitoring = true ∧ i.accessTools = true))

example : Spec.pre { remoteMonitoring := true, accessTools := true } ∧
          Spec.post { remoteMonitoring := true, accessTools := true }
                    { remoteMonitoring := true, accessTools := true } := by
  unfold Spec; decide
