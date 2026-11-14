import ContractForge
open ContractForge

-- UC-customer-register-customer: Register Customer: Register a new customer account with the system.

-- L0 spec

structure Customer where
  name   : String
  email  : String
  deriving DecidableEq, Repr

structure Input where
  customer : Customer
  deriving DecidableEq, Repr

structure Output where
  registered : Bool
  cookie     : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.customer.name ≠ "" ∧ i.customer.email ≠ ""
  post := fun i o => o.registered = true ∧
                     (o.cookie ≠ "" ↔ i.customer.email ≠ "")

example : Spec.pre { customer := { name := "John Doe", email := "johndoe@example.com" } } ∧
          Spec.post { customer := { name := "John Doe", email := "johndoe@example.com" } }
                     { registered := true, cookie := "abc123" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { registered := true,
    cookie := if x.customer.email = "" then "" else "valid-email" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
