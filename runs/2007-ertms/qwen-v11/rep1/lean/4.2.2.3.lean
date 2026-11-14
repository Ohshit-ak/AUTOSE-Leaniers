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
  remainingTimeOuts : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.movementAuthority ≠ "" ∧ i.timeOuts.Nodup
  post := fun i o => 
    o.shortenedAuthority.length ≤ i.movementAuthority.length ∧
    o.remainingTimeOuts.Nodup ∧
    (∀ t ∈ i.timeOuts, t ∈ o.remainingTimeOuts ∨ t = i.movementAuthority.extract (0) (i.movementAuthority.length - o.shortenedAuthority.length)) ∧
    o.shortenedAuthority = i.movementAuthority.extract (0) (o.shortenedAuthority.length)

example : Spec.pre { movementAuthority := "1234567890", timeOuts := ["1234", "5678"] } ∧
          Spec.post { movementAuthority := "1234567890", timeOuts := ["1234", "5678"] }
                    { shortenedAuthority := "123456", remainingTimeOuts := ["5678"] } := by
  unfold Spec; decide
