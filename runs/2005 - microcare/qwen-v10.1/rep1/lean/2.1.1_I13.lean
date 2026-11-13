import ContractForge
open ContractForge

-- 2.1.1/I13: To understand the satisfaction of client the MSIU Admin team will get client feedback from some of the clients and send those documents to field office to enter those into database.
-- compiles: True · rejects_bad_example: None · checked: False

structure ClientFeedback where
  clientName : String
  feedback   : String
  deriving DecidableEq, Repr

structure Input where
  clients     : List ClientFeedback
  clientCount : Nat
  deriving DecidableEq, Repr

structure Output where
  fieldOfficeRecords : List ClientFeedback
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.clientCount
  post := fun i o => o.fieldOfficeRecords.Nodup ∧
                     o.fieldOfficeRecords.length ≤ i.clientCount ∧
                     ∀ f ∈ o.fieldOfficeRecords, ∃ c ∈ i.clients, c.clientName = f.clientName ∧ c.feedback = f.feedback

example : Spec.pre { clients := [{ clientName := "Client1", feedback := "Good" },
                                  { clientName := "Client2", feedback := "Great" }],
                     clientCount := 2 } ∧
          Spec.post { clients := [{ clientName := "Client1", feedback := "Good" },
                                  { clientName := "Client2", feedback := "Great" }],
                      clientCount := 2 }
                    { fieldOfficeRecords := [{ clientName := "Client1", feedback := "Good" },
                                             { clientName := "Client2", feedback := "Great" }] } := by
  unfold Spec; decide
