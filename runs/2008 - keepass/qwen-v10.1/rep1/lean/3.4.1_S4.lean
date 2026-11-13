import ContractForge
open ContractForge

-- 3.4.1/S4: More specifically fields that can be selected for printing are: Backup entries, which contain entries in the back up group, password groups, group tree, title, username, password, URL, notes, creation time, last access, last modification, expires, icon, UUID and attachment.
-- compiles: False · rejects_bad_example: None · checked: False

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
  attachment    : Option String
  deriving DecidableEq, Repr

structure Input where
  entries : List BackupEntry
  deriving DecidableEq, Repr

structure Output where
  selectedEntries : List BackupEntry
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.selectedEntries.length ≤ i.entries.length ∧
                     (∀ e ∈ o.selectedEntries, ∃ e' ∈ i.entries, e = e') ∧
                     (o.selectedEntries.length > 0 ↔
                      o.selectedEntries.contains { passwordGroup := "Backup entries",
                                                  groupTree := "group tree",
                                                  title := "title",
                                                  username := "username",
                                                  password := "password",
                                                  url := "URL",
                                                  notes := "notes",
                                                  creationTime := 0,
                                                  lastAccess := 0,
                                                  lastModification := 0,
                                                  expires := 0,
                                                  icon := "icon",
                                                  uuid := "uuid",
                                                  attachment := none })

example : Spec.pre { entries := [{ passwordGroup := "Backup entries",
                                   groupTree := "group tree",
                                   title := "title",
                                   username := "username",
                                   password := "password",
                                   url := "URL",
                                   notes := "notes",
                                   creationTime := 0,
                                   lastAccess := 0,
                                   lastModification := 0,
                                   expires := 0,
                                   icon := "icon",
                                   uuid := "uuid",
                                   attachment := none }] } ∧
          Spec.post { entries := [{ passwordGroup := "Backup entries",
                                    groupTree := "group tree",
                                    title := "title",
                                    username := "username",
                                    password := "password",
                                    url := "URL",
                                    notes := "notes",
                                    creationTime := 0,
                                    lastAccess := 0,
                                    lastModification := 0,
                                    expires := 0,
                                    icon := "icon",
                                    uuid := "uuid",
                                    attachment := none }] }
                    { selectedEntries := [{ passwordGroup := "Backup entries",
                                            groupTree := "group tree",
                                            title := "title",
                                            username := "username",
                                            password := "password",
                                            url := "URL",
                                            notes := "notes",
                                            creationTime := 0,
                                            lastAccess := 0,
                                            lastModification := 0,
                                            expires := 0,
                                            icon := "icon",
                                            uuid := "uuid",
                                            attachment := none }] } := by
  unfold Spec; decide
