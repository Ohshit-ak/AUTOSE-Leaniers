import ContractForge
open ContractForge

-- 2.2.3.2/S1: Travel history data to be collected for an animal or object should include shipping invoices, animal shelter delivery and adoption receipts, and delivery schedules (including delivery vehicle and driver information).
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  animalID : String
  invoices  : List String
  deliveries : List Delivery
  deriving DecidableEq, Repr

structure Delivery where
  vehicleID : String
  driverName : String
  schedule  : String
  deriving DecidableEq, Repr

structure Output where
  animalID : String
  invoices  : List String
  deliveries : List Delivery
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.animalID ≠ ""
  post := fun i o => o.animalID = i.animalID ∧
                     o.invoices = i.invoices ∧
                     o.deliveries = i.deliveries

example : Spec.pre { animalID := "A123", invoices := ["INV123", "INV456"], deliveries := [] } ∧
          Spec.post { animalID := "A123", invoices := ["INV123", "INV456"], deliveries := [] }
                    { animalID := "A123", invoices := ["INV123", "INV456"], deliveries := [] } := by
  unfold Spec; decide
