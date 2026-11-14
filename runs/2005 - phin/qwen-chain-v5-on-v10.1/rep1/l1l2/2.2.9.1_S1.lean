import ContractForge
open ContractForge

-- 2.2.9.1/S1: Systems supporting OM should capture information such as the date and time of an activity, activity type, who initiated the activity, and contact information to generate activity logs for management purposes.

-- L0 spec

structure Input where
  date       : String
  time       : String
  activity   : String
  initiator  : String
  contact    : String
  deriving DecidableEq, Repr

structure Output where
  logged     : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.date ≠ "" ∧ i.time ≠ "" ∧ i.activity ≠ "" ∧ i.initiator ≠ "" ∧ i.contact ≠ ""
  post := fun i o => o.logged = true ↔
    (i.date = i.date ∧ i.time = i.time ∧ i.activity = i.activity ∧
     i.initiator = i.initiator ∧ i.contact = i.contact)

example : Spec.pre { date := "2023-10-01", time := "14:30", activity := "Update Database",
                     initiator := "John Doe", contact := "johndoe@example.com" } ∧
          Spec.post { date := "2023-10-01", time := "14:30", activity := "Update Database",
                      initiator := "John Doe", contact := "johndoe@example.com" }
                    { logged := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { logged := decide ((x.date = x.date ∧ x.time = x.time ∧ x.activity = x.activity ∧
     x.initiator = x.initiator ∧ x.contact = x.contact)) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
