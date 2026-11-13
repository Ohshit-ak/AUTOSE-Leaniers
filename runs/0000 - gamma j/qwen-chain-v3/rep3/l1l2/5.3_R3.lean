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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { encryptedData := x.customerData.map (·.map encrypt) }
