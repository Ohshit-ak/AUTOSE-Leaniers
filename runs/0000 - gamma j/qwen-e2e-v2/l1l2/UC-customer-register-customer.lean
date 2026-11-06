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

-- L1 architect (success=True)

structure Mid where
  name   : String
  email  : String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.name ≠ "" ∧ i.email ≠ ""
  post := fun i m => m.name = i.name ∧ m.email = i.email

def RegisterContract : Contract Mid Output where
  pre  := fun m => m.name ≠ "" ∧ m.email ≠ ""
  post := fun m o => o.registered = true ∧ o.cookie ≠ ""

theorem po1 : Contract.Compatible ValidateContract RegisterContract := by
  discharge_po [RegisterContract, Spec, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq RegisterContract) Spec := by
  discharge_po [RegisterContract, Spec, ValidateContract]

-- L2 ValidateContract (success=True)

def ValidateContractImpl (i : Input) : Mid := 
  { name := i.name, email := i.email }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  discharge_po [RegisterContract, Spec, ValidateContract, ValidateContractImpl]

-- L2 RegisterContract (success=True)

def RegisterContractImpl (m : Mid) : Output := { registered := true, cookie := "unique-cookie" }

theorem RegisterContractImpl_ok : RegisterContract.Satisfies RegisterContractImpl := by
  discharge_po [RegisterContract, RegisterContractImpl, Spec, ValidateContract]