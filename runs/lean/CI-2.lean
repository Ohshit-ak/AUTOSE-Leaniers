-- CI-2: The WebOrder system shall send an e-mail to System Administrator regarding any technical queries from customers or sales people.
-- checked: None

structure Contract (Input Output : Type) where
  pre  : Input → Prop
  post : Input → Output → Prop

def Spec : Contract (List String) (List String × Bool)
where
  pre input := 
    List.Pairwise (· ≤ ·) input && 
    List.any (fun s => s = "technical query") input

  post input output := 
    let (emails, sent) := output;
    List.Pairwise (· ≤ ·) emails && 
    sent && 
    List.forall (fun s => s = "System Administrator") emails

example : Spec [ "customer", "technical query" ] (["System Administrator"], true) :=
  by
    simp [Spec]
    split
    · simp
    · simp
