import ContractForge
open ContractForge

-- 5.3/R3: The system shall encrypt all customer data in database.

-- L0 spec

structure Input where
  customerData : List String
  encryptedData : List String
  deriving DecidableEq, Repr

structure Output where
  encryptedData : List String
  deriving DecidableEq, Repr

-- A simple encryption function
def encrypt (s : String) : String := "加密" ++ s

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.encryptedData.length = i.customerData.length ∧
                     ∀ s ∈ i.customerData, s ≠ "" →
                     o.encryptedData.contains (encrypt s) = true

example : Spec.pre { customerData := ["name", "email", "address"], encryptedData := [] } ∧
          Spec.post { customerData := ["name", "email", "address"], encryptedData := [] }
                     { encryptedData := ["加密name", "加密email", "加密address"] } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  customerData : List String
  encryptedData : List String
  deriving DecidableEq, Repr

structure Output where
  encryptedData : List String
  deriving DecidableEq, Repr

-- A simple encryption function
def encrypt (s : String) : String := "加密" ++ s

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.encryptedData.length = i.customerData.length ∧
                     ∀ s ∈ i.customerData, s ≠ "" →
                     o.encryptedData.contains (encrypt s) = true

-- Component 1: Encrypt each customer data item
def EncryptContract : Contract (Input customerData' encryptedData') (Output customerData' encryptedData'') where
  pre  := fun i => true
  post := fun i o => o.customerData = i.customerData ∧
                     o.encryptedData = i.encryptedData ++ (i.customerData.filter (· ≠ "") |>
                     List.map (fun s => encrypt s))

-- Component 2: Update encrypted data based on customer data
def UpdateEncryptedDataContract : Contract (Input customerData' encryptedData') (Output customerData' encryptedData'') where
  pre  := fun i => true
  post := fun i o => o.encryptedData.length = i.customerData.length ∧
                     ∀ s ∈ i.customerData, s ≠ "" →
                     o.encryptedData.contains (encrypt s) = true

-- Prove PO1: EncryptContract's assumption follows from Spec's guarantee
theorem PO1_EncryptContract : Contract.Compatible Spec.pre EncryptContract.pre := by
  -- No need to discharge anything here as the preconditions are trivial
  trivial

-- Prove PO1: UpdateEncryptedDataContract's assumption follows from EncryptContract's guarantee
theorem PO1_UpdateEncryptedDataContract : Contract.Compatible EncryptContract.post UpdateEncryptedDataContract.pre := by
  -- No need to discharge anything here as the preconditions are trivial
  trivial

-- Prove PO2: The composition refines the spec
theorem PO2_CompositionRefinesSpec : Contract.Refines (Spec.pre.seq EncryptContract.pre).seq UpdateEncryptedDataContract.post Spec.post := by
  -- Discharge the proof obligations
  discharge_po

-- Example to check the contracts
example : Spec.pre { customerData := ["name", "email", "address"], encryptedData := [] } ∧
          Spec.post { customerData := ["name", "email", "address"], encryptedData := [] }
                     { encryptedData := ["加密name", "加密email", "加密address"] } := by
  unfold Spec; decide