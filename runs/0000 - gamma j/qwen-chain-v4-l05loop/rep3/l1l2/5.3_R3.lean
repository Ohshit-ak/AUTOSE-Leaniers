import ContractForge
open ContractForge

-- 5.3/R3: The system shall encrypt all customer data in database.

-- L0 spec

structure Input where
  customerData : List String
  deriving DecidableEq, Repr

structure Output where
  encryptedData : List String
  deriving DecidableEq, Repr

-- Helper function for encryption (not part of Lean core)
def encrypt (s : String) : String := "encrypted_" ++ s  -- Replace with actual encryption function

def Spec : Contract Input Output where
  pre  := fun i => i.customerData.Nodup
  post := fun i o => o.encryptedData.Nodup ∧
                     o.encryptedData.length = i.customerData.length ∧
                     ∀ s ∈ i.customerData, o.encryptedData.contains (encrypt s) ∧
                     (encrypt s).length = s.length

example : Spec.pre { customerData := [] } ∧ Spec.post { customerData := [] } { encryptedData := [] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { encryptedData := x.customerData.map (fun s => encrypt s) }
