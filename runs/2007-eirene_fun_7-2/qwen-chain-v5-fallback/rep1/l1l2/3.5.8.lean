import ContractForge
open ContractForge

-- 3.5.8: 3.5.8 Requirement 3.5.7 needs further technical specification changes before field implementation can be achieved. (I)

-- L0 spec

structure Area where
  id : Nat
  type : String
  deriving DecidableEq, Repr

structure Input where
  areas : List Area
  deriving DecidableEq, Repr

structure Output where
  areas : List Area
  deriving DecidableEq, Repr

-- An area can be either "broadcast" or "group"
def Spec : Contract Input Output where
  pre  := fun i => i.areas.Nodup ∧
                  i.areas.all (fun a => a.type = "broadcast" ∨ a.type = "group")
  post := fun i o => o.areas = i.areas.filter (fun a => a.type = "broadcast" ∨ a.type = "group")

example : Spec.pre { areas := [{ id := 1, type := "broadcast" },
                                { id := 2, type := "group" }] } ∧
          Spec.post { areas := [{ id := 1, type := "broadcast" },
                                 { id := 2, type := "group" }] }
                    { areas := [{ id := 1, type := "broadcast" },
                                { id := 2, type := "group" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { areas := x.areas.filter (fun a => a.type = "broadcast" ∨ a.type = "group") }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
