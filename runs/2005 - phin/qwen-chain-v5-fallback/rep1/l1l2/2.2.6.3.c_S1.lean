import ContractForge
open ContractForge

-- 2.2.6.3.c/S1: Food sample data should include information about the lot number, batch number, manufacturer name, shipping invoice, temperature, sample type (e.g., dairy - milk, red meat, spice), and product storage condition.

-- L0 spec

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
  pre  := fun i => i.lotNumber ≠ "" ∧ i.batchNumber ≠ "" ∧ i.manufacturer ≠ "" ∧
                 i.shippingInvoice ≠ "" ∧ i.temperature ≥ 10 ∧
                 i.sampleType ≠ "" ∧ i.storageCondition ≠ ""
  post := fun i o => o.lotNumber = i.lotNumber ∧
                     o.batchNumber = i.batchNumber ∧
                     o.manufacturer = i.manufacturer ∧
                     o.shippingInvoice = i.shippingInvoice ∧
                     o.temperature = i.temperature ∧
                     o.sampleType = i.sampleType ∧
                     o.storageCondition = i.storageCondition

example : Spec.pre { lotNumber := "L123", batchNumber := "B456", manufacturer := "ABC Inc.",
                     shippingInvoice := "SI789", temperature := 20, sampleType := "dairy - milk",
                     storageCondition := "refrigerated" } ∧
          Spec.post { lotNumber := "L123", batchNumber := "B456", manufacturer := "ABC Inc.",
                      shippingInvoice := "SI789", temperature := 20, sampleType := "dairy - milk",
                      storageCondition := "refrigerated" }
                    { lotNumber := "L123", batchNumber := "B456", manufacturer := "ABC Inc.",
                      shippingInvoice := "SI789", temperature := 20, sampleType := "dairy - milk",
                      storageCondition := "refrigerated" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { lotNumber := x.lotNumber,
    batchNumber := x.batchNumber,
    manufacturer := x.manufacturer,
    shippingInvoice := x.shippingInvoice,
    temperature := x.temperature,
    sampleType := x.sampleType,
    storageCondition := x.storageCondition }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
