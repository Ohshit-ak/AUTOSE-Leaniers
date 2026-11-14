import ContractForge
open ContractForge

-- 10.5.1/S1: SIM cards shall contain a list of authorised networks so that networks shall be displayed (or automatically selected if automatic network selection has been enabled) in the following order of priority (see [MORANE SIM] for more details): (M)

-- L0 spec

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
  networksDisplayed : List Network
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.sim.networks.Nodup && i.sim.networks.all (fun n => 1 ≤ n.priority)
  post := fun i o =>
    (o.selectedNetwork.isSome ↔ i.automaticSelection) ∧
    (o.networksDisplayed.length ≤ i.sim.networks.length) ∧
    (∀ n ∈ o.networksDisplayed, n ∈ i.sim.networks) ∧
    o.networksDisplayed.length ≤ 100 ∧
    List.Pairwise (fun a b => a.priority ≥ b.priority) o.networksDisplayed

example : Spec.pre { sim := { networks := [{ code := "123", priority := 1 }, { code := "456", priority := 2 }] }, automaticSelection := true } ∧ Spec.post { sim := { networks := [{ code := "123", priority := 1 }, { code := "456", priority := 2 }] }, automaticSelection := true } { selectedNetwork := some { code := "123", priority := 1 }, networksDisplayed := [] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { selectedNetwork := if x.automaticSelection then some (x.sim.networks.headD { code := "", priority := 0 }) else none,
    networksDisplayed := x.sim.networks.filter (fun n => 1 ≤ n.priority) }
