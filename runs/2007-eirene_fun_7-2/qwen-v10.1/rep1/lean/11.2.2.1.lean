import ContractForge
open ContractForge

-- 11.2.2.1: 11.2.2.1 Functional numbers must be unique within the domain of operation. Since the number must be independent of networks, each number must be unique across all networks (including implementation of EIRENE facilities on public networks). (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  functionalNumber : String
  isUnique         : Bool
  deriving DecidableEq, Repr

structure Output where
  unique : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functionalNumber.length = 16 ∧
                   i.functionalNumber.toList.all (·.isDigit) = true
  post := fun i o => (o.unique = true ↔
    i.isUnique = true ∧
    i.functionalNumber.length = 16 ∧
    i.functionalNumber.toList.all (·.isDigit) = true) ∧
    (o.unique = false ↔
    i.isUnique = false)

example : Spec.pre { functionalNumber := "1234567890123456", isUnique := true } ∧
          Spec.post { functionalNumber := "1234567890123456", isUnique := true }
                    { unique := true } := by
  unfold Spec; decide

example : Spec.pre { functionalNumber := "1234567890123456", isUnique := false } ∧
          Spec.post { functionalNumber := "1234567890123456", isUnique := false }
                    { unique := false } := by
  unfold Spec; decide
