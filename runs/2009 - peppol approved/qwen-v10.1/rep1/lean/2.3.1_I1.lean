import ContractForge
open ContractForge

-- 2.3.1/I1: Structural VCD package data: Data that describes the VCD-Package as a whole, e.g. VCD Unique Identifier, VCD issuing time, VCD service provider etc.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  vcdUniqueIdentifier : String
  vcdIssuingTime      : Nat
  vcdServiceProvider  : String
  deriving DecidableEq, Repr

structure Output where
  vcdUniqueIdentifier : String
  vcdIssuingTime      : Nat
  vcdServiceProvider  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.vcdUniqueIdentifier ≠ "" ∧ i.vcdIssuingTime > 0 ∧ i.vcdServiceProvider ≠ ""
  post := fun i o => o.vcdUniqueIdentifier = i.vcdUniqueIdentifier ∧
                     o.vcdIssuingTime = i.vcdIssuingTime ∧
                     o.vcdServiceProvider = i.vcdServiceProvider

example : Spec.pre { vcdUniqueIdentifier := "VCD123", vcdIssuingTime := 1623456789, vcdServiceProvider := "ServiceX" } ∧
          Spec.post { vcdUniqueIdentifier := "VCD123", vcdIssuingTime := 1623456789, vcdServiceProvider := "ServiceX" }
                    { vcdUniqueIdentifier := "VCD123", vcdIssuingTime := 1623456789, vcdServiceProvider := "ServiceX" } := by
  unfold Spec; decide
