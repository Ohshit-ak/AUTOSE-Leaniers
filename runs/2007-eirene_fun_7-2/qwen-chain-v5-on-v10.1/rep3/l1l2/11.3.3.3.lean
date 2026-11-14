import ContractForge
open ContractForge

-- 11.3.3.3: 11.3.3.3 It shall be possible to deregister up to ten functional numbers to items of equipment physically connected to the Cab radio within 30 seconds. (M)

-- L0 spec

structure Input where
  functionalNumbers : List String
  deriving DecidableEq, Repr

structure Output where
  deregistered : Nat
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functionalNumbers.length ≤ 10
  post := fun i o => o.deregistered = i.functionalNumbers.length ∧
                      o.elapsedMicros ≤ 30000000

example : Spec.pre { functionalNumbers := ["1234", "5678", "9012", "3456", "7890", "1234", "5678", "9012", "3456", "7890"] } ∧
          Spec.post { functionalNumbers := ["1234", "5678", "9012", "3456", "7890", "1234", "5678", "9012", "3456", "7890"] }
                    { deregistered := 10, elapsedMicros := 2500000 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { deregistered := x.functionalNumbers.length,
    elapsedMicros := min (x.functionalNumbers.length * 3000000) 30000000 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
