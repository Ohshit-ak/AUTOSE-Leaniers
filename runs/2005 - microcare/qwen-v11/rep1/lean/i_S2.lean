import ContractForge
open ContractForge

-- i/S2: Each distributor will have unique code and detailed descriptions such as name, address, locations and type of business etc. such valid information will help us track information related to sales and distributions.
-- compiles: True · rejects_bad_example: True · checked: True

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
  pre  := fun i => i.distributors.Nodup ∧
                   i.distributors.all (fun d => d.code ≠ "" ∧
                                                d.name ≠ "" ∧
                                                d.address ≠ "" ∧
                                                d.locations.Nodup ∧
                                                d.businessType ≠ "")
  post := fun i o => o.distributors = i.distributors.filter (fun d => d.code ≠ "" ∧
                                                                      d.name ≠ "" ∧
                                                                      d.address ≠ "" ∧
                                                                      d.locations.Nodup ∧
                                                                      d.businessType ≠ "")

example : Spec.pre { distributors := [{ code := "D1", name := "Distributor1", address := "123 Main St", locations := ["Office1"], businessType := "Retail" },
                                       { code := "D2", name := "Distributor2", address := "456 Elm St", locations := ["Office2"], businessType := "Wholesale" }] } ∧
          Spec.post { distributors := [{ code := "D1", name := "Distributor1", address := "123 Main St", locations := ["Office1"], businessType := "Retail" },
                                       { code := "D2", name := "Distributor2", address := "456 Elm St", locations := ["Office2"], businessType := "Wholesale" }] }
                    { distributors := [{ code := "D1", name := "Distributor1", address := "123 Main St", locations := ["Office1"], businessType := "Retail" },
                                       { code := "D2", name := "Distributor2", address := "456 Elm St", locations := ["Office2"], businessType := "Wholesale" }] } := by
  unfold Spec; decide
