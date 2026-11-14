import ContractForge
open ContractForge

-- 7.2.3.10: 7.2.3.10 It shall be possible to register and deregister a functional number in the following way: Initiated by the user and transmitted to the ground: user enters functional number which is transmitted to the network. (M)

-- L0 spec

structure FunctionalNumber where
  number : String
  deriving DecidableEq, Repr

structure Input where
  functionalNumber : FunctionalNumber
  registered      : Bool
  deriving DecidableEq, Repr

structure Output where
  registered      : Bool
  functionalNumber : FunctionalNumber
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functionalNumber.number ≠ ""
  post := fun i o => (o.registered = true ↔ i.registered = false) ∧
                     (o.registered = false → i.functionalNumber.number = o.functionalNumber.number)

example : Spec.pre { functionalNumber := { number := "12345" }, registered := false } ∧
          Spec.post { functionalNumber := { number := "12345" }, registered := false }
                    { registered := true, functionalNumber := { number := "12345" } } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { registered := decide (x.registered = false),
    functionalNumber := x.functionalNumber }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
