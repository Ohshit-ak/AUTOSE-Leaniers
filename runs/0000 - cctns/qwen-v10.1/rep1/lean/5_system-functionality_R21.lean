import ContractForge
open ContractForge

-- 5/system-functionality/R21: The system should support selective encryption of the stored data
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  data : List String
  fieldsToEncrypt : List String
  deriving DecidableEq, Repr

structure Output where
  encryptedData : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.fieldsToEncrypt.Nodup ∧ i.fieldsToEncrypt.all (fun f => i.data.any (fun d => d.contains f))
  post := fun i o => o.encryptedData.length = i.data.length ∧
                     (∀ d ∈ i.data, ∃ e ∈ o.encryptedData, i.fieldsToEncrypt.contains d ∧ e ≠ d) ∧
                     (∀ d ∈ i.data, ¬(i.fieldsToEncrypt.contains d) → o.encryptedData.contains d = i.data.contains d)

example : Spec.pre { data := ["name", "address", "phone"], fieldsToEncrypt := ["name", "phone"] } ∧
          Spec.post { data := ["name", "address", "phone"], fieldsToEncrypt := ["name", "phone"] }
                    { encryptedData := ["encrypted_name", "address", "encrypted_phone"] } := by
  unfold Spec; decide
