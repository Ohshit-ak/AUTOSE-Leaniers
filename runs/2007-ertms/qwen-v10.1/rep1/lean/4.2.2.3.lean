import ContractForge
open ContractForge

-- 4.2.2.3: Together with the movement authority, the on board shall be able to receive one or more time-out(s) for certain sections of the movement authority, and shorten the movement authority accordingly when a time out expires.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  movementAuthority : String
  timeOuts         : List String
  deriving DecidableEq, Repr

structure Output where
  shortenedAuthority : String
  remainingTimeouts : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.movementAuthority ≠ "" ∧ i.timeOuts.Nodup
  post := fun i o => o.shortenedAuthority = i.movementAuthority ∧
                     o.remainingTimeouts = i.timeOuts ∧
                     o.remainingTimeouts.length ≤ i.timeOuts.length ∧
                     (∀ t ∈ i.timeOuts, t ∈ o.remainingTimeouts ∨
                     (o.shortenedAuthority.length < i.movementAuthority.length ∧
                     o.shortenedAuthority = i.movementAuthority[0:t.length]))

example : Spec.pre { movementAuthority := "A1B2C3", timeOuts := ["A1", "C3"] } ∧
          Spec.post { movementAuthority := "A1B2C3", timeOuts := ["A1", "C3"] }
                    { shortenedAuthority := "B2", remainingTimeouts := ["C3"] } := by
  unfold Spec; decide
