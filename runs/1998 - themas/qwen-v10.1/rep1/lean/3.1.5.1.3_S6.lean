import ContractForge
open ContractForge

-- 3.1.5.1.3/S6: When a request to turn off a heating or cooling unit is received, this process shall check the queue of waiting heating and cooling requests.
-- compiles: True · rejects_bad_example: True · checked: True

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
