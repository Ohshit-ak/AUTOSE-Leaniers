import ContractForge
open ContractForge

-- 5.2.2.74: 5.2.2.74 The driver shall be able to terminate communications (voice or data) by selecting another call. (M) Forward calls to driver handheld
-- compiles: False · rejects_bad_example: None · checked: False

structure Call where
  id : Nat
  status : Bool -- true if the call is active
  deriving DecidableEq, Repr

structure Input where
  activeCalls : List Call
  deriving DecidableEq, Repr

structure Output where
  activeCalls : List Call
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.activeCalls.Nodup ∧ i.activeCalls.any (fun c => c.status = true)
  post := fun i o => o.activeCalls = i.activeCalls ∧
                     (o.activeCalls.any (fun c => c.status = true) ↔
                      ∃ c ∈ i.activeCalls, c.id = i.activeCalls.find? (fun c' => c'.status = true).get! ∧
                      o.activeCalls.find? (fun c' => c'.id = c.id).get!.status = false)

example : Spec.pre { activeCalls := [{ id := 1, status := true }, { id := 2, status := false }] } ∧
          Spec.post { activeCalls := [{ id := 1, status := true }, { id := 2, status := false }] }
                    { activeCalls := [{ id := 1, status := false }, { id := 2, status := false }] } := by
  unfold Spec; decide
