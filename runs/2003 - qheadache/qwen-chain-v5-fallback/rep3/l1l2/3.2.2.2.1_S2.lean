import ContractForge
open ContractForge

-- 3.2.2.2.1/S2: Enter your name : ", an Edit Box that can contain 20 characters and a pushbutton with the label "OK".

-- L0 spec

structure Input where
  name : String
  deriving DecidableEq, Repr

structure Output where
  name : String
  statistics : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name.length ≤ 20
  post := fun i o => o.name = i.name ∧
                     (o.statistics = "Game finished. Your name: " ++ i.name)

example : Spec.pre { name := "Alice" } ∧
          Spec.post { name := "Alice" }
                    { name := "Alice", statistics := "Game finished. Your name: Alice" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { name := x.name,
    statistics := "Game finished. Your name: " ++ x.name }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
