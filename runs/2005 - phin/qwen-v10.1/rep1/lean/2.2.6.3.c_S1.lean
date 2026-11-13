import ContractForge
open ContractForge

-- 2.2.6.3.c/S1: Food sample data should include information about the lot number, batch number, manufacturer name, shipping invoice, temperature, sample type (e.g., dairy - milk, red meat, spice), and product storage condition.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  lotNumber      : String
  batchNumber    : String
  manufacturer   : String
  shippingInvoice: String
  temperature    : Nat
  sampleType     : String
  storageCondition: String
  deriving DecidableEq, Repr

structure Output where
  lotNumber      : String
  batchNumber    : String
  manufacturer   : String
  shippingInvoice: String
  temperature    : Nat
  sampleType     : String
  storageCondition: String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.lotNumber ≠ "" ∧ i.batchNumber ≠ "" ∧
                 i.manufacturer ≠ "" ∧ i.shippingInvoice ≠ "" ∧
                 100 ≥ i.temperature ∧
                 (i.sampleType = "dairy - milk" ∨
                  i.sampleType = "red meat" ∨
                  i.sampleType = "spice")
  post := fun i o => o.lotNumber = i.lotNumber ∧
                     o.batchNumber = i.batchNumber ∧
                     o.manufacturer = i.manufacturer ∧
                     o.shippingInvoice = i.shippingInvoice ∧
                     o.temperature = i.temperature ∧
                     o.sampleType = i.sampleType ∧
                     o.storageCondition = i.storageCondition

example : Spec.pre { lotNumber := "L123", batchNumber := "B456", manufacturer := "ABC Inc.",
                     shippingInvoice := "SI789", temperature := 5, sampleType := "dairy - milk",
                     storageCondition := "refrigerated" } ∧
          Spec.post { lotNumber := "L123", batchNumber := "B456", manufacturer := "ABC Inc.",
                      shippingInvoice := "SI789", temperature := 5, sampleType := "dairy - milk",
                      storageCondition := "refrigerated" }
                    { lotNumber := "L123", batchNumber := "B456", manufacturer := "ABC Inc.",
                      shippingInvoice := "SI789", temperature := 5, sampleType := "dairy - milk",
                      storageCondition := "refrigerated" } := by
  unfold Spec; decide
