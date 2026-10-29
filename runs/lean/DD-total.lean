-- DD-total: Cost of a single unit of the selected item Number of units of that item selected; in dollars and cents
-- checked: None

structure Contract (α : Type) where
  pre  : α → Prop
  post : α → Prop

def MoneyCents : Type := Nat

structure DDTotal where
  total : MoneyCents
  deriving Inhabited

def isMoneyCents (n : MoneyCents) : Prop := n ≤ 999999

def Spec : Contract DDTotal DDTotal where
  pre t := isMoneyCents t.total
  post t t' := isMoneyCents t'.total

example : Spec (DDTotal.mk 123456) (DDTotal.mk 123456) := by
  simp
