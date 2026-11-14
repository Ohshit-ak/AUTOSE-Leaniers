import ContractForge
open ContractForge

-- 5.2.3.38: 5.2.3.38 It shall be possible to register and deregister a stock number in one or both of the following ways: (M) automatically using information from on-board systems; automatically via a fixed interface between the locomotive/coach and the radio. Store/retrieve numbers and their details

-- L0 spec

structure StockNumber where
  number : Nat
  details : String
  deriving DecidableEq, Repr

structure Input where
  number : Nat
  details : String
  deriving DecidableEq, Repr

structure Output where
  registered : Bool
  deriving DecidableEq, Repr

-- IMPL: Automatically using information from on-board systems and a fixed interface

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.registered = true ↔
    (i.number > 5 ∧ i.details ≠ "")

example : Spec.pre { number := 10, details := "Details" } ∧
          Spec.post { number := 10, details := "Details" }
                    { registered := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { registered := decide ((x.number > 5 ∧ x.details ≠ "")) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
