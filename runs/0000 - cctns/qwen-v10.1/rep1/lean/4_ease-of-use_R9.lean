import ContractForge
open ContractForge

-- 4/ease-of-use/R9: Where the System employs a graphical user interface, it must allow users to customise it. Customisation should include, but need not be limited to the following changes: menu contents; layout of screens; use of function keys; on-screen colours, fonts and font sizes;
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  menuContents   : List String
  screenLayout   : List String
  functionKeys  : List String
  onScreenColors : List String
  fonts         : List String
  fontSizes     : List Nat
  deriving DecidableEq, Repr

structure Output where
  menuContents   : List String
  screenLayout   : List String
  functionKeys  : List String
  onScreenColors : List String
  fonts         : List String
  fontSizes     : List Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.menuContents = i.menuContents ∧
                     o.screenLayout = i.screenLayout ∧
                     o.functionKeys = i.functionKeys ∧
                     o.onScreenColors = i.onScreenColors ∧
                     o.fonts = i.fonts ∧
                     o.fontSizes = i.fontSizes

example : Spec.pre { menuContents := ["File", "Edit", "View"],
                     screenLayout := ["Home", "Settings", "Help"],
                     functionKeys := ["F1", "F2", "F3"],
                     onScreenColors := ["blue", "green", "red"],
                     fonts := ["Arial", "Times New Roman", "Courier New"],
                     fontSizes := [12, 14, 16] } ∧
          Spec.post { menuContents := ["File", "Edit", "View"],
                      screenLayout := ["Home", "Settings", "Help"],
                      functionKeys := ["F1", "F2", "F3"],
                      onScreenColors := ["blue", "green", "red"],
                      fonts := ["Arial", "Times New Roman", "Courier New"],
                      fontSizes := [12, 14, 16] }
                    { menuContents := ["File", "Edit", "View"],
                      screenLayout := ["Home", "Settings", "Help"],
                      functionKeys := ["F1", "F2", "F3"],
                      onScreenColors := ["blue", "green", "red"],
                      fonts := ["Arial", "Times New Roman", "Courier New"],
                      fontSizes := [12, 14, 16] } := by
  unfold Spec; decide
