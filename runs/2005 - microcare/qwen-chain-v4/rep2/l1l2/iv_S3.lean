import ContractForge
open ContractForge

-- iv/S3: If yes, then the user should mark that Claim (Treatment Form) status as Rejected and send back to VSP.

-- L0 spec

structure Input where
  status  : String
  deriving DecidableEq, Repr

structure Output where
  status  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.status = "Yes"
  post := fun i o => o.status = "Rejected" ∧ o.status ≠ i.status

example : Spec.pre { status := "Yes" } ∧
          Spec.post { status := "Yes" } { status := "Rejected" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { status := "Rejected" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
