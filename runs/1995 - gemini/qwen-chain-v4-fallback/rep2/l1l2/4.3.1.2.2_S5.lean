import ContractForge
open ContractForge

-- 4.3.1.2.2/S5: A client can communicate with an arbitrary number of servers.

-- L0 spec

structure Input where
  clients : List String
  servers : List String
  communications : List (String × String)
  deriving DecidableEq, Repr

structure Output where
  clients : List String
  servers : List String
  communications : List (String × String)
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.clients ≠ [] ∧ i.servers ≠ []
  post := fun i o => o.clients = i.clients ∧
                     o.servers = i.servers ∧
                     o.communications.length = i.clients.length * i.servers.length ∧
                     ∀ c ∈ i.clients, ∀ s ∈ i.servers, (c, s) ∈ o.communications

example : Spec.pre { clients := ["client1", "client2"], servers := ["server1", "server2"], communications := [] } ∧
          Spec.post { clients := ["client1", "client2"], servers := ["server1", "server2"], communications := [] }
                    { clients := ["client1", "client2"], servers := ["server1", "server2"], communications := [("client1", "server1"), ("client1", "server2"), ("client2", "server1"), ("client2", "server2")] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { clients := x.clients, servers := x.servers, communications := List.cartesian_product x.clients x.servers }
