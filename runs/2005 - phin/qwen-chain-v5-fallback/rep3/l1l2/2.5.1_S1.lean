import ContractForge
open ContractForge

-- 2.5.1/S1: Contact information for key response partner organizations should be stored in a local instance of a public health directory for associating to a health event, as described in section 2.2.2 Health event Data of this document.

-- L0 spec

structure ContactInfo where
  organization : String
  phone        : String
  email        : String
  address      : String
  deriving DecidableEq, Repr

structure HealthEvent where
  id          : Nat
  description : String
  contacts    : List ContactInfo
  deriving DecidableEq, Repr

structure Input where
  events : List HealthEvent
  deriving DecidableEq, Repr

structure Output where
  events : List HealthEvent
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.events.Nodup ∧
                 ∀ e ∈ i.events, e.contacts.Nodup ∧
                 ∀ c ∈ e.contacts, c.organization ≠ "" ∧ c.phone ≠ "" ∧ c.email ≠ "" ∧ c.address ≠ ""
  post := fun i o => o.events = i.events.filter (fun e => e.contacts.Nodup ∧
                                                         ∀ c ∈ e.contacts, c.organization ≠ "" ∧ c.phone ≠ "" ∧ c.email ≠ "" ∧ c.address ≠ "")

example : Spec.pre { events := [{ id := 1, description := "Event 1", contacts := [{ organization := "Org1", phone := "1234567890", email := "org1@example.com", address := "123 Main St" }] },
                                 { id := 2, description := "Event 2", contacts := [{ organization := "Org2", phone := "0987654321", email := "org2@example.com", address := "456 Elm St" }] }] } ∧
          Spec.post { events := [{ id := 1, description := "Event 1", contacts := [{ organization := "Org1", phone := "1234567890", email := "org1@example.com", address := "123 Main St" }] },
                                  { id := 2, description := "Event 2", contacts := [{ organization := "Org2", phone := "0987654321", email := "org2@example.com", address := "456 Elm St" }] }] }
                    { events := [{ id := 1, description := "Event 1", contacts := [{ organization := "Org1", phone := "1234567890", email := "org1@example.com", address := "123 Main St" }] },
                                 { id := 2, description := "Event 2", contacts := [{ organization := "Org2", phone := "0987654321", email := "org2@example.com", address := "456 Elm St" }] }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { events := x.events.filter (fun e => e.contacts.Nodup ∧
                                                         ∀ c ∈ e.contacts, c.organization ≠ "" ∧ c.phone ≠ "" ∧ c.email ≠ "" ∧ c.address ≠ "") }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
