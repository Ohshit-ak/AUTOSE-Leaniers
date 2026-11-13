import ContractForge
open ContractForge

-- 3.2.5.2.1/S5: Review Incoming Annotated as well as Un-annotated Digital Imagery [SSS233] All digital messages received by the TCS shall be automatically checked for errors and corrected when possible. [SSS234] All erroneous messages that cannot be corrected by TCS shall be flagged to the operator. [SSS235] The TCS shall provide the capability to log all incoming and outgoing formatted tactical messages. [SSS236]

-- L0 spec

structure Input where
  messages : List String
  corrected : List String
  erroneous : List String
  logged    : List String
  deriving DecidableEq, Repr

structure Output where
  corrected : List String
  erroneous : List String
  logged    : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.messages.Nodup
  post := fun i o => 
    (∀ m ∈ i.messages, 
      (m ∈ o.corrected ∨ m ∈ o.erroneous) ∧
      (m ∈ o.logged ↔ m ∈ i.messages)) ∧
    o.corrected.length + o.erroneous.length = i.messages.length

example : Spec.pre { messages := ["msg1", "msg2", "msg3"],
                     corrected := ["msg1", "msg2", "msg3"],
                     erroneous := [],
                     logged := ["msg1", "msg2", "msg3"] } ∧
          Spec.post { messages := ["msg1", "msg2", "msg3"],
                      corrected := ["msg1", "msg2", "msg3"],
                      erroneous := [],
                      logged := ["msg1", "msg2", "msg3"] }
                    { corrected := ["msg1", "msg2", "msg3"], erroneous := [], logged := ["msg1", "msg2", "msg3"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { corrected := x.corrected,
    erroneous := x.erroneous,
    logged := x.logged }
