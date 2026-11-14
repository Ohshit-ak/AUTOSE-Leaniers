import ContractForge
open ContractForge

-- 3.20.1/S4: The generation can be based on character sets, patterns or can be created according by rules.
-- compiles: False · rejects_bad_example: None · checked: False

structure CharacterSet where
  digits   : Bool
  lower    : Bool
  upper    : Bool
  symbols  : Bool
  deriving DecidableEq, Repr

structure Pattern where
  sequence : String
  repeat   : Nat
  deriving DecidableEq, Repr

structure Rule where
  condition : String
  replacement : String
  deriving DecidableEq, Repr

structure Input where
  length    : Nat
  characterSet : Option CharacterSet
  pattern   : Option Pattern
  rules     : List Rule
  deriving DecidableEq, Repr

structure Output where
  password : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.length > 0
  post := fun i o => o.password.length = i.length ∧
                     (i.characterSet.isNone →
                      o.password.toList.all (fun c => c.isDigit ∨ c.isLower ∨ c.isUpper ∨ c.isSymbol)) ∧
                     (i.pattern.isSome →
                      o.password = (i.pattern.getD { sequence := "", repeat := 1 }).sequence.repeat i.pattern.getD.repeat) ∧
                     (i.rules.Nodup →
                      o.password.toList.all (fun c => ∃ r ∈ i.rules, c = r.condition → r.replacement = c))

example : Spec.pre { length := 10, characterSet := some { digits := true, lower := true, upper := false, symbols := false },
                     pattern := none, rules := [{ condition := "a", replacement := "A" }, { condition := "b", replacement := "B" }] } ∧
          Spec.post { length := 10, characterSet := some { digits := true, lower := true, upper := false, symbols := false },
                      pattern := none, rules := [{ condition := "a", replacement := "A" }, { condition := "b", replacement := "B" }] }
                    { password := "AAbcd12345" } := by
  unfold Spec; decide
