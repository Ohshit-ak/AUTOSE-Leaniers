import ContractForge
open ContractForge

-- 14.2.5: 14.2.5 Within the shunting group, it shall be possible for only one member of the group to transmit the link assurance signal at any time. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure ShuntingGroup where
  members : List String
  transmitting : Option String
  deriving DecidableEq, Repr

structure Input where
  group : ShuntingGroup
  deriving DecidableEq, Repr

structure Output where
  group : ShuntingGroup
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.group.transmitting.isNone ∨
                   (∃ m ∈ i.group.members, i.group.transmitting = some m)
  post := fun i o => o.group.transmitting = i.group.transmitting ∧
                     (o.group.transmitting.isNone ∨
                      (∃ m ∈ i.group.members, o.group.transmitting = some m))

example : Spec.pre { group := { members := ["Alice", "Bob"], transmitting := none } } ∧
         Spec.post { group := { members := ["Alice", "Bob"], transmitting := none } }
                   { group := { members := ["Alice", "Bob"], transmitting := none } } := by
  unfold Spec; decide
