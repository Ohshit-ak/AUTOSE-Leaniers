import ContractForge
open ContractForge

-- 5.6.2/S1: As a train approaches the limits of the coverage of the PLMN it is registered with, it will be necessary for it to register with the next PLMN providing coverage.

-- L0 spec

structure Input where
  currentPlmn : String
  nextPlmn    : String
  deriving DecidableEq, Repr

structure Output where
  registered : Bool
  newPlmn    : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.currentPlmn ≠ "" ∧ i.nextPlmn ≠ ""
  post := fun i o => (o.registered = true ↔ i.currentPlmn = i.nextPlmn) ∧
                     (o.registered = false → o.newPlmn = i.nextPlmn)

example : Spec.pre { currentPlmn := "PLMN1", nextPlmn := "PLMN2" } ∧
          Spec.post { currentPlmn := "PLMN1", nextPlmn := "PLMN2" }
                    { registered := false, newPlmn := "PLMN2" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  registered : Bool
  nextPlmn : String
  deriving DecidableEq, Repr

def RegisterPlmnContract : Contract Input Mid where
  pre  := fun i => i.currentPlmn ≠ "" ∧ i.nextPlmn ≠ ""
  post := fun i m => (m.registered = true ↔ i.currentPlmn = i.nextPlmn) ∧ m.nextPlmn = i.nextPlmn

def UpdateNewPlmnContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (m.registered = false → o.newPlmn = m.nextPlmn) ∧
                     (m.registered = true → o.newPlmn = m.nextPlmn) ∧
                     (o.registered = m.registered)



theorem po1 : Contract.Compatible RegisterPlmnContract UpdateNewPlmnContract := by
  discharge_po1 [RegisterPlmnContract, UpdateNewPlmnContract, Spec]

theorem po2 : Contract.Refines (RegisterPlmnContract.seq UpdateNewPlmnContract) Spec := by
  discharge_po2 [RegisterPlmnContract, UpdateNewPlmnContract, Spec]

-- L2 RegisterPlmnContract (success=True)

def RegisterPlmnContractImpl (x : Input) : Mid :=
  { registered := decide (x.currentPlmn = x.nextPlmn),
    nextPlmn := x.nextPlmn }

theorem RegisterPlmnContractImpl_ok : RegisterPlmnContract.Satisfies RegisterPlmnContractImpl := by
  discharge_po3 [RegisterPlmnContract, RegisterPlmnContractImpl]

-- L2 UpdateNewPlmnContract (success=True)

def UpdateNewPlmnContractImpl (x : Mid) : Output :=
  { registered := x.registered,
    newPlmn := if x.registered = false then x.nextPlmn else if x.registered = true then x.nextPlmn else x.nextPlmn }

theorem UpdateNewPlmnContractImpl_ok : UpdateNewPlmnContract.Satisfies UpdateNewPlmnContractImpl := by
  discharge_po3 [UpdateNewPlmnContract, UpdateNewPlmnContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (UpdateNewPlmnContractImpl ∘ RegisterPlmnContractImpl) :=
  Contract.system_sound po1 po2 RegisterPlmnContractImpl_ok UpdateNewPlmnContractImpl_ok
