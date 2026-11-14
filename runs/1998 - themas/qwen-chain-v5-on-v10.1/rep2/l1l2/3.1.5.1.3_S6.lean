import ContractForge
open ContractForge

-- 3.1.5.1.3/S6: When a request to turn off a heating or cooling unit is received, this process shall check the queue of waiting heating and cooling requests.

-- L0 spec

structure Request where
  unitId : Nat
  status : String
  deriving DecidableEq, Repr

structure Input where
  unitId : Nat
  queue  : List Request
  status : String
  deriving DecidableEq, Repr

structure Output where
  queue  : List Request
  status : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.status = "ON"
  post := fun i o => o.queue = i.queue ∧
                     (o.status = "OFF" ↔
                      ∃ r ∈ i.queue, r.unitId = i.unitId ∧ r.status = "ON")

example : Spec.pre { unitId := 1, queue := [{ unitId := 1, status := "ON" },
                                             { unitId := 2, status := "OFF" }],
                     status := "ON" } ∧
          Spec.post { unitId := 1, queue := [{ unitId := 1, status := "ON" },
                                              { unitId := 2, status := "OFF" }],
                      status := "ON" }
                    { queue := [{ unitId := 1, status := "ON" },
                                { unitId := 2, status := "OFF" }],
                      status := "OFF" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { queue := x.queue,
    status := if ∃ r ∈ x.queue, r.unitId = x.unitId ∧ r.status = "ON" then "OFF" else "ON" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
