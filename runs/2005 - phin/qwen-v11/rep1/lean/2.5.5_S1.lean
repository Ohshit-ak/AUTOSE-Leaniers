import ContractForge
open ContractForge

-- 2.5.5/S1: Systems supporting OM must be able to receive, parse and process messages for laboratory results.
-- compiles: False · rejects_bad_example: None · checked: False

structure LaboratoryResult where
  patientID : Nat
  testCode  : String
  result    : String
  deriving DecidableEq, Repr

structure Input where
  message : String
  deriving DecidableEq, Repr

structure Output where
  parsed  : List LaboratoryResult
  success : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.message ≠ ""
  post := fun i o => (o.success = true ↔
    i.message.toList.all (fun c => c.isDigit || c == ' ' || c == '-') ∧
    i.message.splitOn ' ' = List.mkArray (o.parsed.length + 1) (fun _ => "")
    .map (fun s => { patientID := s.toList.takeWhile (fun c => c.isDigit).length,
                     testCode := s.splitOn '-',
                     result := s.dropWhile (fun c => c.isDigit) })
    .filter (fun lr => lr.testCode.length > 0 ∧ lr.result ≠ ""))
    ∧ o.parsed.length > 0

example : Spec.pre { message := "1234-TEST1-POS 5678-TEST2-NEG" } ∧
          Spec.post { message := "1234-TEST1-POS 5678-TEST2-NEG" }
                    { parsed := [{ patientID := 1234, testCode := ["TEST1"], result := "POS" },
                                 { patientID := 5678, testCode := ["TEST2"], result := "NEG" }],
                      success := true } := by
  unfold Spec; decide
