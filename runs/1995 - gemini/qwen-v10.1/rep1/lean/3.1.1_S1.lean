import ContractForge
open ContractForge

-- 3.1.1/S1: Control information must be transferred, typically in the form of commands and replies from users, to telescope and instruments.
-- compiles: True · rejects_bad_example: True · checked: True

structure Command where
  type : String
  payload : String
  deriving DecidableEq, Repr

structure Reply where
  status : String
  message : String
  deriving DecidableEq, Repr

structure Input where
  command : Command
  deriving DecidableEq, Repr

structure Output where
  reply : Reply
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.command.type ≠ ""
  post := fun i o => o.reply.status = "success" ↔
    (i.command.type = "control" ∧ i.command.payload ≠ "")

example : Spec.pre { command := { type := "control", payload := "set_focus" } } ∧
          Spec.post { command := { type := "control", payload := "set_focus" } }
                    { reply := { status := "success", message := "Focus set" } } := by
  unfold Spec; decide
