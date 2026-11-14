import ContractForge
open ContractForge

-- 4.6.4.7: When a train has received an emergency stop ETCS shall command the emergency brake.
-- compiles: True · rejects_bad_example: None · checked: False

structure Train where
  id : Nat
  status : String
  deriving DecidableEq, Repr

structure Input where
  trains : List Train
  deriving DecidableEq, Repr

structure Output where
  trains : List Train
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.trains.Nodup
  post := fun i o => o.trains = i.trains ∧
                     (∀ t ∈ o.trains, t.status = "emergency brake" ↔
                      ∃ t' ∈ i.trains, t'.id = t.id ∧ t'.status = "emergency stop")

example : Spec.pre { trains := [] } ∧ Spec.post { trains := [] } { trains := [] } := by
  unfold Spec; decide
