import ContractForge
open ContractForge

-- 11.3.3.5: 11.3.3.5 An EIRENE mobile shall remove the displayed functional number and provide an indication to the user that deregistration has taken place. (M)

-- L0 spec

structure FunctionalNumber where
  number : String
  deriving DecidableEq, Repr

structure Input where
  functionalNumber : FunctionalNumber
  userIndication   : String
  succeeded        : Bool
  deriving DecidableEq, Repr

structure Output where
  userIndication : String
  succeeded      : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functionalNumber.number ≠ ""
  post := fun i o => (o.succeeded = true ↔ i.userIndication = "Deregistration successful")
                  ∧ (o.succeeded = false ↔ i.userIndication = "Deregistration failed")
                  ∧ o.userIndication = "Deregistration successful" ∨ o.userIndication = "Deregistration failed"

example : Spec.pre { functionalNumber := { number := "12345678" }, userIndication := "Deregistration successful", succeeded := true } ∧
          Spec.post { functionalNumber := { number := "12345678" }, userIndication := "Deregistration successful", succeeded := true }
                    { userIndication := "Deregistration successful", succeeded := true } := by
  unfold Spec; decide

example : Spec.pre { functionalNumber := { number := "12345" }, userIndication := "Please confirm deregistration", succeeded := false } ∧
          Spec.post { functionalNumber := { number := "12345" }, userIndication := "Please confirm deregistration", succeeded := false }
                    { userIndication := "Deregistration failed", succeeded := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { userIndication := x.userIndication, succeeded := x.userIndication = "Deregistration successful" }
