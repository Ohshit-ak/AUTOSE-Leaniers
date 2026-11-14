import ContractForge
open ContractForge

-- 3.3.2.2/S2: It has to be defined whether a VCD package can have its own validity or if its validity is only based on the contained information.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  vcd_package_validity : Nat
  contained_information_validity : Nat
  deriving DecidableEq, Repr

structure Output where
  validity : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => (o.validity = i.vcd_package_validity ↔
    i.vcd_package_validity = 0 ∨ i.vcd_package_validity ≥ i.contained_information_validity) ∧
                     (o.validity = 0 ∨ o.validity ≤ i.contained_information_validity)

example : Spec.pre { vcd_package_validity := 30, contained_information_validity := 60 } ∧ Spec.post { vcd_package_validity := 30, contained_information_validity := 60 } { validity := 0 } := by
  unfold Spec; decide
