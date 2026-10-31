-- DD-shipping-date: Date when the specified order is shipped; format MM/DD/YYYY
-- checked: False

structure Input where
  rawShippingDate : String

structure Output where
  validShippingDate : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.rawShippingDate.length = 10 ∧
                  i.rawShippingDate[0] ∈ '0'..'9' ∧
                  i.rawShippingDate[1] ∈ '0'..'9' ∧
                  i.rawShippingDate[3] = '/' ∧
                  i.rawShippingDate[4] ∈ '0'..'9' ∧
                  i.rawShippingDate[5] ∈ '0'..'9' ∧
                  i.rawShippingDate[6] = '/' ∧
                  i.rawShippingDate[7] ∈ '0'..'9' ∧
                  i.rawShippingDate[8] ∈ '0'..'9' ∧
                  i.rawShippingDate[9] ∈ '0'..'9'
  post := fun i o => o.validShippingDate = true ↔
                      i.rawShippingDate.length = 10 ∧
                      i.rawShippingDate[0] ∈ '0'..'9' ∧
                      i.rawShippingDate[1] ∈ '0'..'9' ∧
                      i.rawShippingDate[3] = '/' ∧
                      i.rawShippingDate[4] ∈ '0'..'9' ∧
                      i.rawShippingDate[5] ∈ '0'..'9' ∧
                      i.rawShippingDate[6] = '/' ∧
                      i.rawShippingDate[7] ∈ '0'..'9' ∧
                      i.rawShippingDate[8] ∈ '0'..'9' ∧
                      i.rawShippingDate[9] ∈ '0'..'9'

example : Spec.pre ⟨"12/31/2023"⟩ ∧ Spec.post ⟨"12/31/2023"⟩ ⟨true⟩ := by
  simp [Spec]
