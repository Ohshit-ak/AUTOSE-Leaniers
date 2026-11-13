import ContractForge
open ContractForge

-- 5.3.9/S2: Each of the other cabs on the train will be contacted using its functional number (registered by the other drivers prior to the establishment of the call).

-- L0 spec

structure FunctionalNumber where
  number : Nat
  deriving DecidableEq, Repr

structure Input where
  functionalNumbers : List FunctionalNumber
  deriving DecidableEq, Repr

structure Output where
  contacted : List FunctionalNumber
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functionalNumbers.Nodup
  post := fun i o => o.contacted = i.functionalNumbers ∧
                     o.contacted.length = i.functionalNumbers.length

example : Spec.pre { functionalNumbers := [{ number := 1 }, { number := 2 }] } ∧
          Spec.post { functionalNumbers := [{ number := 1 }, { number := 2 }] }
                    { contacted := [{ number := 1 }, { number := 2 }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { contacted := x.functionalNumbers }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
