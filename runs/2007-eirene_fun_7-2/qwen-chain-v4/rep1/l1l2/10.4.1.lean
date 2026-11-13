import ContractForge
open ContractForge

-- 10.4.1: 10.4.1 A mobile may be a member of a number of groups. It shall be possible to activate or deactivate the mobiles subscription to these groups. (M)

-- L0 spec

structure Input where
  mobileId : Nat
  groups   : List Nat
  deriving DecidableEq, Repr

structure Output where
  mobileId : Nat
  groups   : List Nat
  active   : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.groups.Nodup
  post := fun i o => o.mobileId = i.mobileId ∧
                     o.groups = i.groups ∧
                     (o.active = true ↔ i.groups.Nodup ∧ 0 < o.groups.length)

example : Spec.pre { mobileId := 123, groups := [456, 789] } ∧
          Spec.post { mobileId := 123, groups := [456, 789] }
                    { mobileId := 123, groups := [456, 789], active := true } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  groups   : List Nat
  active   : Bool
  deriving DecidableEq, Repr

def ComputeGroupsContract : Contract Input Mid where
  pre  := fun i => i.groups.Nodup
  post := fun i m => m.groups = i.groups ∧ m.active = true ↔ i.groups.Nodup ∧ 0 < i.groups.length

def FinalizeOutputContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.mobileId = m.groups.head ∧
                     o.groups = m.groups ∧
                     o.active = m.active
