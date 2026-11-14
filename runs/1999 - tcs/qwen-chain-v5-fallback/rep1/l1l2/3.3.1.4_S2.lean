import ContractForge
open ContractForge

-- 3.3.1.4/S2: The TCS shall provide an interface between the TCS and external data storage systems. [SSS317] The TCS shall have the functionality to transfer digital data as well as digital imagery to and from external data storage systems. [SSS318] Details of the Tactical Control System (TCS) to external data storage interface will be defined in the TCS to External Data Storage IDD, TCS256.

-- L0 spec

structure Input where
  data : List String
  deriving DecidableEq, Repr

structure Output where
  transferred : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.data ≠ []
  post := fun i o => o.transferred = true ↔
    (i.data.length = 0 → o.transferred = false) ∧
    (i.data.length > 0 →
      ∃ transferredData ∈ i.data, transferredData ∈ i.data ∧
      (transferredData = "digital data" ∨ transferredData = "digital imagery"))

example : Spec.pre { data := ["digital data", "digital imagery"] } ∧
          Spec.post { data := ["digital data", "digital imagery"] }
                    { transferred := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { transferred := 
      (x.data.length = 0 → false) ∧
      (x.data.length > 0 →
        ∃ transferredData ∈ x.data, transferredData ∈ x.data ∧
        (transferredData = "digital data" ∨ transferredData = "digital imagery"))
  }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
