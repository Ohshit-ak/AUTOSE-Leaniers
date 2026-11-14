import ContractForge
open ContractForge

-- 4.4.1.2: Information received shall not influence the traction unit(s) with in-operative cabs.

-- L0 spec

structure TractionUnit where
  cabStatus : Bool
  deriving DecidableEq, Repr

structure Input where
  units : List TractionUnit
  information : String
  deriving DecidableEq, Repr

structure Output where
  units : List TractionUnit
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.units.all (fun u => u.cabStatus)
  post := fun i o => o.units = i.units ∧
                     (o.units.all (fun u => u.cabStatus ↔ i.units.any (fun u' => u' = u)))

example : Spec.pre { units := [{ cabStatus := true }, { cabStatus := true }],
                     information := "some data" } ∧
          Spec.post { units := [{ cabStatus := true }, { cabStatus := true }],
                      information := "some data" }
                    { units := [{ cabStatus := true }, { cabStatus := true }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { units := x.units }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
