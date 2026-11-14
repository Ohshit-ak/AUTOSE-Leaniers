import ContractForge
open ContractForge

-- 3.4.1/S4: More specifically fields that can be selected for printing are: Backup entries, which contain entries in the back up group, password groups, group tree, title, username, password, URL, notes, creation time, last access, last modification, expires, icon, UUID and attachment.
-- compiles: True · rejects_bad_example: None · checked: True

structure BackupEntry where
  passwordGroup : String
  groupTree     : String
  title         : String
  username      : String
  password      : String
  url           : String
  notes         : String
  creationTime  : Nat
  lastAccess    : Nat
  lastModification : Nat
  expires       : Nat
  icon          : String
  uuid          : String
  attachment    : String
  deriving DecidableEq, Repr

structure Input where
  entries : List BackupEntry
  deriving DecidableEq, Repr

structure Output where
  selectedEntries : List BackupEntry
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.selectedEntries = i.entries.filter (fun e => 
    e.passwordGroup ≠ "" ∨ e.groupTree ≠ "" ∨ e.title ≠ "" ∨ e.username ≠ "" ∨
    e.password ≠ "" ∨ e.url ≠ "" ∨ e.notes ≠ "" ∨ 0 < e.creationTime ∨
    0 < e.lastAccess ∨ 0 < e.lastModification ∨ 0 < e.expires ∨
    e.icon ≠ "" ∨ e.uuid ≠ "" ∨ e.attachment ≠ "")

example : Spec.pre { entries := [{ passwordGroup := "grp1", groupTree := "tree1", title := "title1", username := "user1", password := "pass1", url := "url1", notes := "notes1", creationTime := 1, lastAccess := 2, lastModification := 3, expires := 4, icon := "icon1", uuid := "uuid1", attachment := "att1" }] } ∧
          Spec.post { entries := [{ passwordGroup := "grp1", groupTree := "tree1", title := "title1", username := "user1", password := "pass1", url := "url1", notes := "notes1", creationTime := 1, lastAccess := 2, lastModification := 3, expires := 4, icon := "icon1", uuid := "uuid1", attachment := "att1" }] }
                    { selectedEntries := [{ passwordGroup := "grp1", groupTree := "tree1", title := "title1", username := "user1", password := "pass1", url := "url1", notes := "notes1", creationTime := 1, lastAccess := 2, lastModification := 3, expires := 4, icon := "icon1", uuid := "uuid1", attachment := "att1" }] } := by
  unfold Spec; decide
