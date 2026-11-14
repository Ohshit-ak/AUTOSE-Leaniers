import ContractForge
open ContractForge

-- 2.1.1/I13: To understand the satisfaction of client the MSIU Admin team will get client feedback from some of the clients and send those documents to field office to enter those into database.

-- L0 spec

structure ClientFeedback where
  clientName : String
  feedback   : String
  deriving DecidableEq, Repr

structure Input where
  clients : List ClientFeedback
  sampleSize : Nat
  deriving DecidableEq, Repr

structure Output where
  fieldOfficeEntries : List ClientFeedback
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.sampleSize ≤ i.clients.length
  post := fun i o => o.fieldOfficeEntries.length = i.sampleSize ∧
                     ∀ f ∈ o.fieldOfficeEntries, ∃ c ∈ i.clients, f.clientName = c.clientName ∧ f.feedback = c.feedback

example : Spec.pre { clients := [{ clientName := "Alice", feedback := "Great service" },
                                  { clientName := "Bob", feedback := "Not satisfied" }],
                     sampleSize := 2 } ∧
          Spec.post { clients := [{ clientName := "Alice", feedback := "Great service" },
                                  { clientName := "Bob", feedback := "Not satisfied" }],
                      sampleSize := 2 }
                    { fieldOfficeEntries := [{ clientName := "Alice", feedback := "Great service" },
                                             { clientName := "Bob", feedback := "Not satisfied" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩
