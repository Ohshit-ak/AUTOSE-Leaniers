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

-- L1 architect (success=False)

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

-- Component 1: Check if the input name and email are not empty
def CheckInputContract : Contract Input Bool := 
  def pre  := fun i => i.name ≠ "" ∧ i.email ≠ ""
  def post := fun i r => r
  <|
  by
    discharge_po

-- Component 2: Generate a cookie if the input is valid
def GenerateCookieContract : Contract Bool Output := 
  def pre  := fun b => b
  def post := fun b o => o.cookie ≠ ""
  <|
  by
    discharge_po

-- Prove PO1: CheckInputContract's postcondition is compatible with Spec's precondition
example : Contract.Compatible (CheckInputContract.post) Spec.pre := by
  unfold CheckInputContract Spec; simp; discharge_po

-- Prove PO2: The composition of the two contracts refines the spec
example : Contract.Refines (CheckInputContract.seq GenerateCookieContract) Spec := by
  unfold CheckInputContract GenerateCookieContract Spec; simp; discharge_po