import ContractForge
open ContractForge

-- 3.3/S2: The TCS shall provide the capability to interface with equipment necessary to provide connectivity with standard DoD tactical (VHF, UHF, and UHF/VHF) radios, Mobile Subscriber Equipment, and military and commercial satellite communications equipment. [SSS285] The TCS shall interface with external mission tasking systems (e.g., receive tasking orders, coordinate mission certification). [SSS286] The TCS shall provide the system functionality necessary to interface with the data terminal. [SSS287] The TCS shall provide the system functionality to allow interfacing with external systems via a local area network. [SSS288] The TCS shall provide external interfaces to launch and recovery systems. [SSS289]
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  taskingOrders : List String
  deriving DecidableEq, Repr

structure Output where
  taskingAcknowledged : Bool
  networkInterfaces   : Nat
  launchRecovery      : Bool
  deriving DecidableEq, Repr

-- IMPL: The TCS interfaces with external mission tasking systems and data terminal, and provides interfaces via LAN and launch/recovery systems.

def Spec : Contract Input Output where
  pre  := fun i => i.taskingOrders.Nodup
  post := fun i o =>
    o.taskingAcknowledged = true ↔ i.taskingOrders.length > 0 ∧
    o.networkInterfaces = i.taskingOrders.length ∧
    o.launchRecovery = true

example : Spec.pre { taskingOrders := ["order1", "order2"] } ∧
          Spec.post { taskingOrders := ["order1", "order2"] }
                    { taskingAcknowledged := true, networkInterfaces := 2, launchRecovery := true } := by
  unfold Spec; decide
