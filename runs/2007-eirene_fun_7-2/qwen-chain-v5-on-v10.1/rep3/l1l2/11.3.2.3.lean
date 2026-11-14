import ContractForge
open ContractForge

-- 11.3.2.3: 11.3.2.3 It shall be possible to register up to ten functional numbers to items of equipment physically connected to the Cab radio within 30 seconds. (M)

-- L0 spec

structure Input where
  functionalNumbers : List Nat
  items             : List String
  deriving DecidableEq, Repr

structure Output where
  registered        : Nat
  elapsedMicros    : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functionalNumbers.length ≤ 10
  post := fun i o => o.registered = i.functionalNumbers.length ∧
                      o.registered ≤ 10 ∧
                      o.elapsedMicros ≤ 30000000

example : Spec.pre { functionalNumbers := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], items := ["item1", "item2", "item3"] } ∧
          Spec.post { functionalNumbers := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], items := ["item1", "item2", "item3"] }
                    { registered := 10, elapsedMicros := 2500000 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { registered := x.functionalNumbers.length,
    elapsedMicros := 30000000 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
