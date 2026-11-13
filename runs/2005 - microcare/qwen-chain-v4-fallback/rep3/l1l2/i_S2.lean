import ContractForge
open ContractForge

-- i/S2: Each distributor will have unique code and detailed descriptions such as name, address, locations and type of business etc. such valid information will help us track information related to sales and distributions.

-- L0 spec

structure Distributor where
  code      : String
  name      : String
  address   : String
  locations : List String
  businessType : String
  deriving DecidableEq, Repr

structure Input where
  distributors : List Distributor
  deriving DecidableEq, Repr

structure Output where
  distributors : List Distributor
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.distributors.Nodup
  post := fun i o => o.distributors = i.distributors ∧
                     ∀ d ∈ o.distributors, d.code ≠ "" ∧
                     d.name ≠ "" ∧
                     d.address ≠ "" ∧
                     d.locations.Nodup ∧
                     d.businessType ≠ ""

example : Spec.pre { distributors := [{ code := "D1", name := "Distributor1", address := "123 Main St", locations := ["Office1"], businessType := "Retail" },
                                       { code := "D2", name := "Distributor2", address := "456 Elm St", locations := ["Office2"], businessType := "Wholesale" }] } ∧
          Spec.post { distributors := [{ code := "D1", name := "Distributor1", address := "123 Main St", locations := ["Office1"], businessType := "Retail" },
                                       { code := "D2", name := "Distributor2", address := "456 Elm St", locations := ["Office2"], businessType := "Wholesale" }] }
                    { distributors := [{ code := "D1", name := "Distributor1", address := "123 Main St", locations := ["Office1"], businessType := "Retail" },
                                       { code := "D2", name := "Distributor2", address := "456 Elm St", locations := ["Office2"], businessType := "Wholesale" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { distributors := x.distributors }
