import ContractForge
open ContractForge

-- 12.2.1: 12.2.1 It should be possible to transfer text messages between ground and mobile(s) through the EIRENE system. (O)

-- L0 spec

structure Input where
  groundMessage : String
  mobileNumbers : List String
  deriving DecidableEq, Repr

structure Output where
  sentMessages : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.groundMessage ≠ "" ∧ i.mobileNumbers.Nodup
  post := fun i o => o.sentMessages.length = i.mobileNumbers.length ∧
                     (∀ m ∈ i.mobileNumbers, o.sentMessages.contains m ↔
                      m.length = 11 ∧ m.all Char.isDigit = true) ∧
                     (∀ m ∈ o.sentMessages, ∃ n ∈ i.mobileNumbers, m = n)

example : Spec.pre { groundMessage := "Hello", mobileNumbers := [] } ∧ Spec.post { groundMessage := "Hello", mobileNumbers := [] } { sentMessages := [] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { sentMessages := x.mobileNumbers.filter (fun m => m.length = 11 ∧ m.all (fun c => Char.isDigit c)) }
