-- 1.4/I3: Confirm Orders
-- checked: True

inductive Status where
  | pending : Status
  | confirmed : Status

structure Order where
  id : Nat
  status : Status

structure Input where
  orders : List Order

structure Output where
  orders : List Order

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o =>
    (∀ ord_out ∈ o.orders, ord_out.status = Status.confirmed) ∧
    List.Perm (i.orders.map (fun ord => ord.id)) (o.orders.map (fun ord => ord.id))

example : Spec.pre ⟨[]⟩ ∧ Spec.post ⟨[]⟩ ⟨[]⟩ := by
  constructor
  simp [Spec]
  simp [Spec]
