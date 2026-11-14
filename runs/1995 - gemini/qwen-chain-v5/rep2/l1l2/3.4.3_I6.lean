import ContractForge
open ContractForge

-- 3.4.3/I6: The number of main packages of software must be kept to a minimum to facilitate maintenance, but compatibly with the need to have the right degree of modularity.

-- L0 spec

structure Input where
  mainPackages : List String
  deriving DecidableEq, Repr

structure Output where
  mainPackages : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mainPackages.Nodup
  post := fun i o => o.mainPackages = i.mainPackages ∧ o.mainPackages.Nodup

example : Spec.pre { mainPackages := ["pkg1", "pkg2", "pkg3"] } ∧
          Spec.post { mainPackages := ["pkg1", "pkg2", "pkg3"] }
                    { mainPackages := ["pkg1", "pkg2", "pkg3"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { mainPackages := x.mainPackages }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
