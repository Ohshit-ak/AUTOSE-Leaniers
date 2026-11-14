import ContractForge
open ContractForge

-- 3.3.1.6/S2: The TCS shall have an interface to a source of current navigation information. [SSS321] As a minimum this information will include the location of all data terminals, launch and recovery sites, and the controlling TCS.

-- L0 spec

structure Input where
  locationData : List String
  deriving DecidableEq, Repr

structure Output where
  geopositionalData : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.locationData.Nodup
  post := fun i o => o.geopositionalData.Nodup ∧
                     (∀ loc ∈ i.locationData, ∃ gp ∈ o.geopositionalData, gp = loc) ∧
                     (o.geopositionalData.length = i.locationData.length) ∧
                     (o.geopositionalData = i.locationData → o.geopositionalData = [])

example : Spec.pre { locationData := [] } ∧ Spec.post { locationData := [] } { geopositionalData := [] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { geopositionalData := x.locationData }
