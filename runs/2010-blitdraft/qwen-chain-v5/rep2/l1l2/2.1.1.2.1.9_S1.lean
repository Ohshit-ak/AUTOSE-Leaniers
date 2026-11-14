import ContractForge
open ContractForge

-- 2.1.1.2.1.9/S1: The system shall perform a search on the [system name] user display name and user name columns in the user tables to find the user and verify the user's existence.

-- L0 spec

structure Input where
  displayName : String
  userName    : String
  userTables  : List String
  deriving DecidableEq, Repr

structure Output where
  exists_ : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.displayName ≠ "" ∨ i.userName ≠ ""
  post := fun i o => o.exists_ = true ↔
    (i.userTables.any (fun table => table.contains i.displayName) ∨
     i.userTables.any (fun table => table.contains i.userName))

example : Spec.pre { displayName := "John Doe", userName := "johndoe", userTables := [] } ∧ Spec.post { displayName := "John Doe", userName := "johndoe", userTables := [] } { exists_ := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { exists_ := decide ((x.userTables.any (fun table => table.contains x.displayName) ∨
     x.userTables.any (fun table => table.contains x.userName))) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
