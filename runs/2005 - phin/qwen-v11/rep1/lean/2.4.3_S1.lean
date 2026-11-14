import ContractForge
open ContractForge

-- 2.4.3/S1: Systems supporting OM should generate electronic data dictionaries for dynamic data (or other user-defined data descriptions to assist with effective data exchange), line lists, activity logs, aggregate data, and call-back lists to assist the emergency response group and investigators in responding to and containing a health event.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  dynamicData : List String
  lineLists    : List String
  activityLogs : List String
  aggregateData : List String
  callbackLists : List String
  deriving DecidableEq, Repr

structure Output where
  dataDictionary : List String
  lineList       : List String
  activityLog    : List String
  aggregateData  : List String
  callbackList   : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.dynamicData.Nodup ∧ i.lineLists.Nodup ∧ i.activityLogs.Nodup ∧
                 i.aggregateData.Nodup ∧ i.callbackLists.Nodup
  post := fun i o => o.dataDictionary = i.dynamicData ∧
                     o.lineList = i.lineLists ∧
                     o.activityLog = i.activityLogs ∧
                     o.aggregateData = i.aggregateData ∧
                     o.callbackList = i.callbackLists

example : Spec.pre { dynamicData := ["data1", "data2"], lineLists := ["list1", "list2"],
                     activityLogs := ["log1", "log2"], aggregateData := ["agg1", "agg2"],
                     callbackLists := ["cb1", "cb2"] } ∧
          Spec.post { dynamicData := ["data1", "data2"], lineLists := ["list1", "list2"],
                      activityLogs := ["log1", "log2"], aggregateData := ["agg1", "agg2"],
                      callbackLists := ["cb1", "cb2"] }
                    { dataDictionary := ["data1", "data2"], lineList := ["list1", "list2"],
                      activityLog := ["log1", "log2"], aggregateData := ["agg1", "agg2"],
                      callbackList := ["cb1", "cb2"] } := by
  unfold Spec; decide
