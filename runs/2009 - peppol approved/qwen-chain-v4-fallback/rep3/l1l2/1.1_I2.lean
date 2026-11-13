import ContractForge
open ContractForge

-- 1.1/I2: 2. In order to create the VCD, an implemented IT system will have to collect certificates and attestations from existing registries. It also enables the economic operator to add self-declarations or other documents of formal qualification.

-- L0 spec

structure Certificate where
  name    : String
  issuer  : String
  document: String
  deriving DecidableEq, Repr

structure SelfDeclaration where
  name        : String
  document    : String
  deriving DecidableEq, Repr

structure Input where
  certificates : List Certificate
  selfDeclarations : List SelfDeclaration
  deriving DecidableEq, Repr

structure Output where
  vcd : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.certificates.Nodup ∧ i.selfDeclarations.Nodup
  post := fun i o => (o.vcd.length = i.certificates.length + i.selfDeclarations.length) ∧
                     (∀ c ∈ i.certificates, o.vcd.contains c.document) ∧
                     (∀ sd ∈ i.selfDeclarations, o.vcd.contains sd.document)

example : Spec.pre { certificates := [{ name := "Cert1", issuer := "Issuer1", document := "Doc1" }],
                     selfDeclarations := [{ name := "SD1", document := "Doc2" }] } ∧
          Spec.post { certificates := [{ name := "Cert1", issuer := "Issuer1", document := "Doc1" }],
                      selfDeclarations := [{ name := "SD1", document := "Doc2" }] }
                    { vcd := ["Doc1", "Doc2"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { vcd := x.certificates.map (.document) ++ x.selfDeclarations.map (.document) }
