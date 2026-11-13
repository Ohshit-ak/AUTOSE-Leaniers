import ContractForge
open ContractForge

-- 10.5.1/S1: SIM cards shall contain a list of authorised networks so that networks shall be displayed (or automatically selected if automatic network selection has been enabled) in the following order of priority (see [MORANE SIM] for more details): (M)
-- compiles: False · rejects_bad_example: None · checked: False

structure Network where
  code : String
  priority : Nat
  deriving DecidableEq, Repr

structure SIM where
  networks : List Network
  deriving DecidableEq, Repr

structure Input where
  sim : SIM
  automaticSelection : Bool
  deriving DecidableEq, Repr

structure Output where
  selectedNetwork : Option Network
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.sim.networks.Nodup
  post := fun i o => 
    (o.selectedNetwork = some n ↔
      (i.automaticSelection = true →
        ∃ n ∈ i.sim.networks, n.priority = 1) ∧
      (i.automaticSelection = false →
        ∃ n ∈ i.sim.networks, n.code = "default"))) ∧
    (o.selectedNetwork = none ↔
      (i.automaticSelection = false ∧
       ∀ n ∈ i.sim.networks, n.code ≠ "default"))

example : Spec.pre { sim := { networks := [{ code := "M", priority := 1 },
                                            { code := "default", priority := 2 }] },
                     automaticSelection := true } ∧
          Spec.post { sim := { networks := [{ code := "M", priority := 1 },
                                             { code := "default", priority := 2 }] },
                      automaticSelection := true }
                    { selectedNetwork := some { code := "M", priority := 1 } } := by
  unfold Spec; decide
