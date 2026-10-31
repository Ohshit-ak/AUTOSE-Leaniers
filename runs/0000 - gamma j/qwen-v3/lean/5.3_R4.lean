-- 5.3/R4: The system shall auto detect IP DOS attacks and block IP automatically.
-- checked: True

structure Input where
  ipAddr : String
  attacksDetected : Nat
  deriving DecidableEq, Repr

structure Output where
  ipBlocked : Bool
  attacksDetected : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.attacksDetected > 0
  post := fun i o => o.ipBlocked = true ∧ o.attacksDetected = i.attacksDetected ∧
                     (o.ipBlocked = false → o.attacksDetected = i.attacksDetected)

example : Spec.pre { ipAddr := "192.168.1.1", attacksDetected := 5 } ∧
          Spec.post { ipAddr := "192.168.1.1", attacksDetected := 5 }
                    { ipBlocked := true, attacksDetected := 5 } := by
  unfold Spec; decide
