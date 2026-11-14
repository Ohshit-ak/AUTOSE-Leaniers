import ContractForge
open ContractForge

-- 5.3.12/S1: The Cab radio shall be able to receive, display and store incoming short (SMS) text messages (see section 12).

-- L0 spec

structure Input where
  messages : List String
  deriving DecidableEq, Repr

structure Output where
  displayed : String
  stored    : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.messages.length ≤ 1 ∧ i.messages.any (fun m => m.length ≤ 160)
  post := fun i o => o.displayed = i.messages.head?.getD "" ∧
                     o.stored = i.messages.head?.getD "" ∧
                     o.displayed = o.stored

example : Spec.pre { messages := ["short message"] } ∧
          Spec.post { messages := ["short message"] }
                    { displayed := "short message", stored := "short message" } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { displayed := x.messages.head?.getD "",
    stored := x.messages.head?.getD "" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
