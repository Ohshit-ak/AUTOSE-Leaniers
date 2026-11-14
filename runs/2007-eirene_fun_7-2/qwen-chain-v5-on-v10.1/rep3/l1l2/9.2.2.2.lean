import ContractForge
open ContractForge

-- 9.2.2.2: 9.2.2.2 Every on-train function shall be identified by a unique standard number. (M)

-- L0 spec

structure Function where
  number : Nat
  name   : String
  deriving DecidableEq, Repr

structure Input where
  functions : List Function
  deriving DecidableEq, Repr

structure Output where
  functions : List Function
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functions.Nodup
  post := fun i o => o.functions = i.functions ∧
                     ∀ f ∈ o.functions, 0 < f.number ∧
                     ∃ f2 ∈ o.functions, f2.number ≠ f.number

example : Spec.pre { functions := [{ number := 1, name := "Function1" },
                                    { number := 2, name := "Function2" }] } ∧
          Spec.post { functions := [{ number := 1, name := "Function1" },
                                    { number := 2, name := "Function2" }] }
                    { functions := [{ number := 1, name := "Function1" },
                                    { number := 2, name := "Function2" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { functions := x.functions.filter (fun f => 0 < f.number) }
