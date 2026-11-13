import ContractForge
open ContractForge

-- 7.2.2.3: 7.2.2.3 For some users, particularly for shunting team leaders, up to twenty valid numbers may be stored for one controller type. In these cases, the identities of the controllers corresponding to these valid numbers shall be displayed with an audible and visual prompt for one to be selected. The number of the controller selected shall then be used to establish the call. If no selection is made by the user within 10 seconds the radio shall abandon the call attempt. (O)
-- compiles: False · rejects_bad_example: None · checked: False

structure Controller where
  id : Nat
  deriving DecidableEq, Repr

structure Input where
  controllers : List Controller
  selected    : Option Nat
  timeout     : Nat
  deriving DecidableEq, Repr

structure Output where
  selected    : Option Nat
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.controllers.Nodup ∧ i.timeout = 10
  post := fun i o => o.selected = i.selected ∧
                     (o.selected.isSome →
                      ∃ c ∈ i.controllers, c.id = o.selected.getD 0) ∧
                     o.elapsedMicros ≤ 10000000

example : Spec.pre { controllers := [{ id := 1 }, { id := 2 }, { id := 3 }],
                     selected := some 2, timeout := 10 } ∧
          Spec.post { controllers := [{ id := 1 }, { id := 2 }, { id := 3 }],
                      selected := some 2, timeout := 10,
                      elapsedMicros := 9999999 } := by
  unfold Spec; decide
