import ContractForge
open ContractForge

-- 7.2.2.3: 7.2.2.3 For some users, particularly for shunting team leaders, up to twenty valid numbers may be stored for one controller type. In these cases, the identities of the controllers corresponding to these valid numbers shall be displayed with an audible and visual prompt for one to be selected. The number of the controller selected shall then be used to establish the call. If no selection is made by the user within 10 seconds the radio shall abandon the call attempt. (O)

-- L0 spec

structure Controller where
  id : Nat
  deriving DecidableEq, Repr

structure Input where
  controllers : List Controller
  selectedId  : Option Nat
  deriving DecidableEq, Repr

structure Output where
  selectedId : Option Nat
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.controllers.Nodup ∧ i.controllers.length ≤ 20
  post := fun i o => o.selectedId.isSome ↔
    (o.elapsedMicros ≤ 10000000 ∧
     ∃ id ∈ i.controllers.map Controller.id, o.selectedId.getD id = id) ∨
    (o.elapsedMicros = 10000000 ∧ o.selectedId = none)

example : Spec.pre { controllers := [{ id := 1 }, { id := 2 }, { id := 3 }],
                     selectedId := none } ∧
          Spec.post { controllers := [{ id := 1 }, { id := 2 }, { id := 3 }],
                      selectedId := none }
                    { selectedId := some 1, elapsedMicros := 5000000 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { selectedId := x.selectedId,
    elapsedMicros := if x.selectedId.isSome then
      let id := x.selectedId.get!;
      if ∃ c ∈ x.controllers, c.id = id then
        5000000
      else
        10000000
    else
      10000000 }
