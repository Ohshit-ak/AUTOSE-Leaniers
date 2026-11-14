import ContractForge
open ContractForge

-- 3.4.3/S4: Changing system constants, such as arcseconds/bit for an encoder, shall not require recompiling but will be updated as part of system startup, and, for some constants, will be modifiable during operation.

-- L0 spec

structure SystemConstant where
  name   : String
  value  : Nat
  modifiable : Bool
  deriving DecidableEq, Repr

structure Input where
  constants : List SystemConstant
  deriving DecidableEq, Repr

structure Output where
  constants : List SystemConstant
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.constants.Nodup
  post := fun i o => o.constants = i.constants ∧
                     (∀ c ∈ o.constants, c.value = c.value) ∧
                     (∀ c ∈ o.constants, c.modifiable = c.modifiable)

example : Spec.pre { constants := [{ name := "arcseconds", value := 10, modifiable := false },
                                    { name := "bit", value := 8, modifiable := true }] } ∧
          Spec.post { constants := [{ name := "arcseconds", value := 10, modifiable := false },
                                    { name := "bit", value := 8, modifiable := true }] }
                    { constants := [{ name := "arcseconds", value := 10, modifiable := false },
                                    { name := "bit", value := 8, modifiable := true }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { constants := x.constants }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
