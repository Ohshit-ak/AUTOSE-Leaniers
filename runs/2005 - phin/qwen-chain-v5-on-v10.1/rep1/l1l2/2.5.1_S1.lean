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
  pre  := fun i => i.events.Nodup
  post := fun i o => o.events = i.events ∧
                     (∀ e ∈ o.events, e.contacts.Nodup ∧
                      ∀ c ∈ e.contacts, c.organization ≠ "" ∧ c.phone ≠ "" ∧ c.email ≠ "" ∧ c.address ≠ "")

example : Spec.pre { events := [{ id := 1, description := "Event 1", contacts := [{ organization := "Org1", phone := "1234567890", email := "org1@example.com", address := "123 Main St" }] },
                                 { id := 2, description := "Event 2", contacts := [{ organization := "Org2", phone := "0987654321", email := "org2@example.com", address := "456 Elm St" }] }] } ∧
          Spec.post { events := [{ id := 1, description := "Event 1", contacts := [{ organization := "Org1", phone := "1234567890", email := "org1@example.com", address := "123 Main St" }] },
                                  { id := 2, description := "Event 2", contacts := [{ organization := "Org2", phone := "0987654321", email := "org2@example.com", address := "456 Elm St" }] }] }
                    { events := [{ id := 1, description := "Event 1", contacts := [{ organization := "Org1", phone := "1234567890", email := "org1@example.com", address := "123 Main St" }] },
                                 { id := 2, description := "Event 2", contacts := [{ organization := "Org2", phone := "0987654321", email := "org2@example.com", address := "456 Elm St" }] }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { events := x.events.map (fun e =>
    { id := e.id,
      description := e.description,
      contacts := e.contacts.filter (fun c =>
        c.organization ≠ "" ∧
        c.phone ≠ "" ∧
        c.email ≠ "" ∧
        c.address ≠ "")
    })
  }
