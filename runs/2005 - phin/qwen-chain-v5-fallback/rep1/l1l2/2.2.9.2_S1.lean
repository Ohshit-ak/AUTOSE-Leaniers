import ContractForge
open ContractForge

-- 2.2.9.2/S1: Activity logs, which are tools for investigators to track their actions during a case, should be supported.

-- L0 spec

structure Activity where
  investigator : String
  action      : String
  timestamp   : Nat
  deriving DecidableEq, Repr

structure Input where
  activities : List Activity
  deriving DecidableEq, Repr

structure Output where
  activities : List Activity
  deriving DecidableEq, Repr

-- An activity log must be unique and must not be modified.
def UniqueActivity (a : Activity) : Bool :=
  a.investigator ≠ "" ∧ a.action ≠ "" ∧ 0 < a.timestamp

def Spec : Contract Input Output where
  pre  := fun i => i.activities.Nodup ∧ i.activities.all (fun a => UniqueActivity a)
  post := fun i o => o.activities = i.activities ∧
                     o.activities.Nodup ∧ o.activities.all (fun a => UniqueActivity a)

example : Spec.pre { activities := [{ investigator := "Alice", action := "opened case", timestamp := 123456789 },
                                      { investigator := "Bob", action := "closed case", timestamp := 987654321 }] } ∧
          Spec.post { activities := [{ investigator := "Alice", action := "opened case", timestamp := 123456789 },
                                      { investigator := "Bob", action := "closed case", timestamp := 987654321 }] }
                    { activities := [{ investigator := "Alice", action := "opened case", timestamp := 123456789 },
                                      { investigator := "Bob", action := "closed case", timestamp := 987654321 }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { activities := x.activities }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
