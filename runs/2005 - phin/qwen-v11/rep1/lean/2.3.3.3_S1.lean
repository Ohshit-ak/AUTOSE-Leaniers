import ContractForge
open ContractForge

-- 2.3.3.3/S1: Systems supporting OM should be able to create new contacts from existing case records, and should also identify the contact type.
-- compiles: True · rejects_bad_example: True · checked: True

structure Contact where
  name       : String
  contactType: String
  deriving DecidableEq, Repr

structure CaseRecord where
  name       : String
  contactType: String
  deriving DecidableEq, Repr

structure Input where
  caseRecords : List CaseRecord
  deriving DecidableEq, Repr

structure Output where
  newContacts : List Contact
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.caseRecords.Nodup
  post := fun i o => o.newContacts.length = i.caseRecords.length ∧
                     ∀ c ∈ i.caseRecords, ∃ nc ∈ o.newContacts, nc.name = c.name ∧
                     nc.contactType = c.contactType

example : Spec.pre { caseRecords := [{ name := "Alice", contactType := "Family" },
                                      { name := "Bob", contactType := "Work" }] } ∧
          Spec.post { caseRecords := [{ name := "Alice", contactType := "Family" },
                                       { name := "Bob", contactType := "Work" }] }
                    { newContacts := [{ name := "Alice", contactType := "Family" },
                                      { name := "Bob", contactType := "Work" }] } := by
  unfold Spec; decide
