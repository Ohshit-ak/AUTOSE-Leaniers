import ContractForge
open ContractForge

-- 2.2.6.7/S1: Information about batch shipments of specimens/samples that are transferred to test laboratories or other facilities must be collected, including the shipper (e.g., UPS, FedEx), shipment tracking number, and the sending organization's contact information.
-- compiles: True · rejects_bad_example: None · checked: True

structure Shipment where
  shipper   : String
  tracking  : String
  contact   : String
  deriving DecidableEq, Repr

structure Input where
  shipments : List Shipment
  deriving DecidableEq, Repr

structure Output where
  shipments : List Shipment
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.shipments.Nodup ∧
                  ∀ s ∈ i.shipments, s.shipper ≠ "" ∧ s.tracking ≠ "" ∧ s.contact ≠ ""
  post := fun i o => o.shipments = i.shipments.filter (fun s => s.shipper ≠ "" ∧ s.tracking ≠ "" ∧ s.contact ≠ "")

example : Spec.pre { shipments := [{ shipper := "UPS", tracking := "1Z2345678901234567",
                                      contact := "John Doe" },
                                    { shipper := "FedEx", tracking := "1Z987654321098765432",
                                      contact := "Jane Smith" }] } ∧
          Spec.post { shipments := [{ shipper := "UPS", tracking := "1Z2345678901234567",
                                      contact := "John Doe" },
                                    { shipper := "FedEx", tracking := "1Z987654321098765432",
                                      contact := "Jane Smith" }] }
                    { shipments := [{ shipper := "UPS", tracking := "1Z2345678901234567",
                                      contact := "John Doe" },
                                    { shipper := "FedEx", tracking := "1Z987654321098765432",
                                      contact := "Jane Smith" }] } := by
  unfold Spec; decide
