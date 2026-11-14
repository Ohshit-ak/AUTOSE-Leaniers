import ContractForge
open ContractForge

-- 3.1.1/S1: Control information must be transferred, typically in the form of commands and replies from users, to telescope and instruments.
-- compiles: True · rejects_bad_example: True · checked: True

structure Command where
  type  : String
  params: String
  deriving DecidableEq, Repr

structure Reply where
  status : String
  data   : String
  deriving DecidableEq, Repr

structure Input where
  command : Command
  deriving DecidableEq, Repr

structure Output where
  reply   : Reply
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.command.type ≠ ""
  post := fun i o => o.reply.status = "OK" ↔
                     (i.command.type = "TELESCOPE" ∨ i.command.type = "INSTRUMENT")

example : Spec.pre { command := { type := "TELESCOPE", params := "focus 5" } } ∧
          Spec.post { command := { type := "TELESCOPE", params := "focus 5" } }
                    { reply := { status := "OK", data := "Focus adjusted" } } := by
  unfold Spec; decide
