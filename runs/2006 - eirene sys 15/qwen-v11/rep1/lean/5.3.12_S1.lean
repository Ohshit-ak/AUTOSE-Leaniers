import ContractForge
open ContractForge

-- 5.3.12/S1: The Cab radio shall be able to receive, display and store incoming short (SMS) text messages (see section 12).
-- compiles: True · rejects_bad_example: True · checked: True

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
