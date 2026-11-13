import ContractForge
open ContractForge

-- UC-customer-register-customer: Register Customer: Register a new customer account with the system.

-- L0 spec

structure Customer where
  name   : String
  email  : String
  deriving DecidableEq, Repr

structure Input where
  name   : String
  email  : String
  deriving DecidableEq, Repr

structure Output where
  registered : Bool
  cookie     : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ i.email ≠ ""
  post := fun i o => (o.registered = true ↔
    i.name ≠ "" ∧ i.email ≠ "") ∧
    o.cookie ≠ ""

example : Spec.pre { name := "John Doe", email := "johndoe@example.com" } ∧
          Spec.post { name := "John Doe", email := "johndoe@example.com" }
                    { registered := true, cookie := "abc123" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  name   : String
  email  : String
  ok     : Bool
  deriving DecidableEq, Repr

def RegistrationContract : Contract Input Mid where
  pre  := fun i => i.name ≠ "" ∧ i.email ≠ ""
  post := fun i m => m.name = i.name ∧ m.email = i.email ∧ m.ok = true ↔ i.name ≠ "" ∧ i.email ≠ ""

def GenerateCookieContract : Contract Mid Output where
  pre  := fun m => m.ok = true
  post := fun m o => o.registered = true ∧ o.cookie ≠ ""

theorem po1 : Contract.Compatible RegistrationContract GenerateCookieContract := by
  discharge_po1 [RegistrationContract, GenerateCookieContract, Spec]

theorem po2 : Contract.Refines (RegistrationContract.seq GenerateCookieContract) Spec := by
  discharge_po2 [RegistrationContract, GenerateCookieContract, Spec]

-- L2 RegistrationContract (success=True)

def RegistrationContractImpl (x : Input) : Mid :=
  { name := x.name, email := x.email, ok := true }

theorem RegistrationContractImpl_ok : RegistrationContract.Satisfies RegistrationContractImpl := by
  discharge_po3 [RegistrationContract, RegistrationContractImpl]

-- L2 GenerateCookieContract (success=True)

def GenerateCookieContractImpl (x : Mid) : Output :=
  { registered := true, cookie := "unique-cookie-value" }

theorem GenerateCookieContractImpl_ok : GenerateCookieContract.Satisfies GenerateCookieContractImpl := by
  discharge_po3 [GenerateCookieContract, GenerateCookieContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (GenerateCookieContractImpl ∘ RegistrationContractImpl) :=
  Contract.system_sound po1 po2 RegistrationContractImpl_ok GenerateCookieContractImpl_ok
