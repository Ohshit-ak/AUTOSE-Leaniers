import ContractForge
open ContractForge

-- 2.3.1/I1: Structural VCD package data: Data that describes the VCD-Package as a whole, e.g. VCD Unique Identifier, VCD issuing time, VCD service provider etc.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  vcdUniqueIdentifier : String
  issuingTime         : Nat
  serviceProvider     : String
  deriving DecidableEq, Repr

structure Output where
  vcdUniqueIdentifier : String
  issuingTime         : Nat
  serviceProvider     : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.vcdUniqueIdentifier ≠ "" ∧ i.issuingTime > 0 ∧ i.serviceProvider ≠ ""
  post := fun i o => o.vcdUniqueIdentifier = i.vcdUniqueIdentifier ∧
                     o.issuingTime = i.issuingTime ∧
                     o.serviceProvider = i.serviceProvider

example : Spec.pre { vcdUniqueIdentifier := "VCD-12345", issuingTime := 1628534400, serviceProvider := "MyService" } ∧
          Spec.post { vcdUniqueIdentifier := "VCD-12345", issuingTime := 1628534400, serviceProvider := "MyService" }
                    { vcdUniqueIdentifier := "VCD-12345", issuingTime := 1628534400, serviceProvider := "MyService" } := by
  unfold Spec; decide
