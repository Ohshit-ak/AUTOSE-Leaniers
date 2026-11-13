import ContractForge
open ContractForge

-- Design Constraints/S2: All the level of details will have a master table in order to update as per the program requirements.

-- L0 spec

structure Input where
  distributorId : Nat
  voucherDetails : String
  deriving DecidableEq, Repr

structure Output where
  updated : Bool
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.distributorId ≠ 0 ∧ i.voucherDetails ≠ ""
  post := fun i o => o.updated = true ↔
    (o.message = "Distributor master information updated successfully." ∧
     i.voucherDetails = "new details" ∨
     o.message = "No changes needed as the details are already up to date.")

example : Spec.pre { distributorId := 1, voucherDetails := "new details" } ∧
          Spec.post { distributorId := 1, voucherDetails := "new details" }
                    { updated := true, message := "Distributor master information updated successfully." } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { updated := true, message := if x.voucherDetails = "new details" then "Distributor master information updated successfully." else "No changes needed as the details are already up to date." }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
