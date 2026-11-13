import ContractForge
open ContractForge

-- 2.2.6.7/S1: Information about batch shipments of specimens/samples that are transferred to test laboratories or other facilities must be collected, including the shipper (e.g., UPS, FedEx), shipment tracking number, and the sending organization's contact information.

-- L0 spec

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
  pre  := fun i => i.shipments.Nodup
  post := fun i o => o.shipments = i.shipments ∧
                     ∀ s ∈ o.shipments, s.shipper ≠ "" ∧ s.tracking ≠ "" ∧ s.contact ≠ ""

example : Spec.pre { shipments := [{ shipper := "UPS", tracking := "1Z2345678901234567",
                                      contact := "John Doe" },
                                    { shipper := "FedEx", tracking := "1Z9876543210987654",
                                      contact := "Jane Smith" }] } ∧
          Spec.post { shipments := [{ shipper := "UPS", tracking := "1Z2345678901234567",
                                      contact := "John Doe" },
                                    { shipper := "FedEx", tracking := "1Z9876543210987654",
                                      contact := "Jane Smith" }] }
                    { shipments := [{ shipper := "UPS", tracking := "1Z2345678901234567",
                                      contact := "John Doe" },
                                    { shipper := "FedEx", tracking := "1Z9876543210987654",
                                      contact := "Jane Smith" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { shipments := x.shipments }
