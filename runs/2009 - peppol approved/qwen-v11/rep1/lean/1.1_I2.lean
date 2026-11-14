import ContractForge
open ContractForge

-- 1.1/I2: 2. In order to create the VCD, an implemented IT system will have to collect certificates and attestations from existing registries. It also enables the economic operator to add self-declarations or other documents of formal qualification.
-- compiles: False · rejects_bad_example: None · checked: False

structure Certificate where
  name   : String
  value  : String
  deriving DecidableEq, Repr

structure Document where
  name   : String
  value  : String
  deriving DecidableEq, Repr

structure Input where
  certificates : List Certificate
  documents    : List Document
  deriving DecidableEq, Repr

structure Output where
  vcd : List (Certificate ∨ Document)
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.certificates.Nodup ∧ i.documents.Nodup
  post := fun i o => o.vcd.length = i.certificates.length + i.documents.length ∧
                     (∀ c ∈ i.certificates, o.vcd.contains c) ∧
                     (∀ d ∈ i.documents, o.vcd.contains d)

example : Spec.pre { certificates := [{ name := "Cert1", value := "Val1" }],
                     documents := [{ name := "Doc1", value := "Val2" }] } ∧
          Spec.post { certificates := [{ name := "Cert1", value := "Val1" }],
                      documents := [{ name := "Doc1", value := "Val2" }] }
                    { vcd := [{ name := "Cert1", value := "Val1" }, { name := "Doc1", value := "Val2" }] } := by
  unfold Spec; decide
