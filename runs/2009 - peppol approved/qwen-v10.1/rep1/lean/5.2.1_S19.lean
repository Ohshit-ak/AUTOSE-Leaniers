import ContractForge
open ContractForge

-- 5.2.1/S19: Structural data of evidence will provide guidance for foreign contracting authorities to understand the evidences contained within a VCD and they can trust that general information since it is provided by national VCD service providers that take the role of trusted parties.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  vcdId : Nat
  evidence : List String
  deriving DecidableEq, Repr

structure Output where
  trusted : Bool
  guidance : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.vcdId ≠ 0
  post := fun i o => o.trusted = true ∧
                     (o.guidance = "The structural data of evidence will provide guidance for foreign contracting authorities to understand the evidences contained within a VCD and they can trust that general information since it is provided by national VCD service providers that take the role of trusted parties." ↔
                      i.e.evidence.Nodup ∧
                      i.e.evidence.all (fun e => e ≠ ""))

example : Spec.pre { vcdId := 1, evidence := ["evidence1", "evidence2"] } ∧
          Spec.post { vcdId := 1, evidence := ["evidence1", "evidence2"] }
                    { trusted := true, guidance := "The structural data of evidence will provide guidance for foreign contracting authorities to understand the evidences contained within a VCD and they can trust that general information since it is provided by national VCD service providers that take the role of trusted parties." } := by
  unfold Spec; decide
