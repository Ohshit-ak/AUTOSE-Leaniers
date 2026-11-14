import ContractForge
open ContractForge

-- 2.5.10/S1: Systems supporting OM must be able to create and send messages for countermeasure administration requests.

-- L0 spec

structure Input where
  countermeasure : String
  dose           : Nat
  patientID      : String
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  messageID : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.countermeasure ≠ "" ∧ 0 < i.dose ∧ i.patientID ≠ ""
  post := fun i o => o.sent = true ↔
    (o.messageID ≠ "" ∧
     o.messageID.length ≤ 100 ∧
     o.messageID.toList.all (fun c => c.isAlphanum) = true)

example : Spec.pre { countermeasure := "vaccine", dose := 2, patientID := "P12345" } ∧
          Spec.post { countermeasure := "vaccine", dose := 2, patientID := "P12345" }
                    { sent := true, messageID := "MSG12345" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { sent := true, messageID := "MSG" ++ x.patientID.take 100 }
