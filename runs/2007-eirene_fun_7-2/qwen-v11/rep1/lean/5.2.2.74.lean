import ContractForge
open ContractForge

-- 5.2.2.74: 5.2.2.74 The driver shall be able to terminate communications (voice or data) by selecting another call. (M) Forward calls to driver handheld
-- compiles: True · rejects_bad_example: False · checked: False

structure Call where
  id     : Nat
  driver : Bool
  status : String
  deriving DecidableEq, Repr

structure Input where
  calls      : List Call
  driverId   : Nat
  newCallId  : Nat
  deriving DecidableEq, Repr

structure Output where
  calls      : List Call
  succeeded  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.driverId ∈ i.calls.map (·.id) ∧ i.newCallId ∈ i.calls.map (·.id)
  post := fun i o => o.succeeded ↔
    (∃ c ∈ i.calls, c.driver = true ∧ c.id = i.driverId ∧
     (∃ nc ∈ i.calls, nc.id = i.newCallId ∧
      (c.status = "voip" → nc.status = "voip") ∨
      (c.status = "data" → nc.status = "data")))

example : Spec.pre { calls := [{ id := 1, driver := true, status := "voip" },
                               { id := 2, driver := false, status := "data" }],
                     driverId := 1, newCallId := 2 } ∧
          Spec.post { calls := [{ id := 1, driver := true, status := "voip" },
                                 { id := 2, driver := false, status := "data" }],
                      driverId := 1, newCallId := 2 }
                    { calls := [{ id := 1, driver := true, status := "voip" },
                                { id := 2, driver := false, status := "data" }],
                      succeeded := true } := by
  unfold Spec; decide
