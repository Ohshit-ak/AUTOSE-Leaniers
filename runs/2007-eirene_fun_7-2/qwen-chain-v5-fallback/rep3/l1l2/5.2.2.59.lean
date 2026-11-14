import ContractForge
open ContractForge

-- 5.2.2.59: 5.2.2.59 Automatic confirmation of receipt of Railway emergency calls will be used to provide a means of determining which trains have received a Railway emergency call (see section 13). (I) Terminate calls

-- L0 spec

structure Call where
  trainId : Nat
  callType : String
  received : Bool
  deriving DecidableEq, Repr

structure Input where
  calls : List Call
  deriving DecidableEq, Repr

structure Output where
  confirmedCalls : List Call
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.calls.length > 0
  post := fun i o =>
    (∀ c ∈ o.confirmedCalls, c.callType = "Railway emergency" ∧ c.received = true) ∧
    o.confirmedCalls.length ≤ i.calls.length ∧
    ∀ c ∈ i.calls, c.callType = "Railway emergency" → c.received = true → c ∈ o.confirmedCalls ∧
    (∀ c ∈ i.calls, c.callType ≠ "Railway emergency" → c ∉ o.confirmedCalls)

example : Spec.pre { calls := [{ trainId := 1, callType := "Railway emergency", received := true },
                                 { trainId := 2, callType := "Routine check", received := false }] } ∧
          Spec.post { calls := [{ trainId := 1, callType := "Railway emergency", received := true },
                                 { trainId := 2, callType := "Routine check", received := false }] }
                    { confirmedCalls := [{ trainId := 1, callType := "Railway emergency", received := true }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { confirmedCalls := x.calls.filter (fun c => c.callType = "Railway emergency" ∧ c.received = true) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
