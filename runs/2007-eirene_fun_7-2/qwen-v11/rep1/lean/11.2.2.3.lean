import ContractForge
open ContractForge

-- 11.2.2.3: 11.2.2.3 If alphanumeric numbers are applied by a national railway, the railway will be responsible for the translation to unique numeric functional numbers compatible with the EIRENE specification. (I)
-- compiles: True · rejects_bad_example: True · checked: True

structure FunctionalNumber where
  alphanumeric : String
  deriving DecidableEq, Repr

structure NumericFunctionalNumber where
  number : Nat
  deriving DecidableEq, Repr

structure Input where
  alphanumericNumbers : List FunctionalNumber
  deriving DecidableEq, Repr

structure Output where
  numericNumbers : List NumericFunctionalNumber
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.alphanumericNumbers.Nodup
  post := fun i o => o.numericNumbers.Nodup ∧
                     (∀ fn ∈ i.alphanumericNumbers, ∃ nf ∈ o.numericNumbers, nf.number = 10000 + fn.alphanumeric.length) ∧
                     (∀ nf ∈ o.numericNumbers, ∃ fn ∈ i.alphanumericNumbers, nf.number = 10000 + fn.alphanumeric.length)

example : Spec.pre { alphanumericNumbers := [] } ∧ Spec.post { alphanumericNumbers := [] } { numericNumbers := [] } := by
  unfold Spec; decide
