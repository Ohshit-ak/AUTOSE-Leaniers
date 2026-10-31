-- 5.3/R5: The system shall detect consecutive failed login attempts.
-- checked: True

structure Input where
  username : String
  attempts : List String
  deriving DecidableEq, Repr

structure Output where
  detected : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => true
  post := fun i o => o.detected = true ↔ i.attempts.length ≥ 3 ∧
                     i.attempts.all (fun x => x = i.username)

example : Spec.pre { username := "user1", attempts := ["user1", "user1", "user1"] } ∧
          Spec.post { username := "user1", attempts := ["user1", "user1", "user1"] }
                    { detected := true } := by
  unfold Spec; decide
