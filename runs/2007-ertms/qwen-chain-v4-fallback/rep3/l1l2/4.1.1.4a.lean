import ContractForge
open ContractForge

-- 4.1.1.4a: The trackside shall be able to send information for the calculation of speed profiles.

-- L0 spec

structure Input where
  speed : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  profile : List Nat
  sum : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.speed ≤ 1000
  post := fun i o => o.valid = true ∧
                     o.profile.length = 10 ∧
                     o.profile.all (fun p => 0 ≤ p ∧ p ≤ 100) ∧
                     o.profile.sum = i.speed

example : Spec.pre { speed := 500 } ∧
          Spec.post { speed := 500 }
                    { valid := true, profile := [50, 50, 50, 50, 50, 50, 50, 50, 50, 50], sum := 500 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { valid := true,
    profile := (x.speed / 10 :: List.replicate 9 (x.speed / 10)),
    sum := 10 * (x.speed / 10) }
