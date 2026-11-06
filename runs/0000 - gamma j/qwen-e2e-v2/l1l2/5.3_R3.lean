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

structure Mid where
  customerData : List String
  encryptedData : List String
  deriving DecidableEq, Repr

def EncryptCustomerDataContract : Contract Input Mid where
  pre  := fun i => true
  post := fun i m => m.encryptedData.length = i.customerData.length ∧
                     ∀ s ∈ i.customerData, s ≠ "" →
                     m.encryptedData.contains (encrypt s) = false

def FinalizeEncryptionContract : Contract Mid Output where
  pre  := fun m => ∀ s ∈ m.customerData, s ≠ "" →
                   m.encryptedData.contains (encrypt s) = true
  post := fun m o => o.encryptedData = m.encryptedData

theorem po1 : Contract.Compatible EncryptCustomerDataContract FinalizeEncryptionContract := by
  unfold Contract.Compatible EncryptCustomerDataContract FinalizeEncryptionContract
  intro i m _ h
  simp only at h
  exact h.2.2

theorem po2 : Contract.Refines (EncryptCustomerDataContract.seq FinalizeEncryptionContract) Spec := by
  unfold Contract.Refines Contract.seq EncryptCustomerDataContract FinalizeEncryptionContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨hp, hq, _⟩, ho⟩
  simp only at *
  rw [ho, hp, hq]