import ContractForge
open ContractForge

-- 2.1.1/S1: Systems designed to support OM must offer configuration flexibility so that new data fields, entities, entity types and relationship types may be added to capture information unique to each particular health event.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  dataFields   : List String
  entities     : List String
  entityTypes  : List String
  relationshipTypes : List String
  deriving DecidableEq, Repr

structure Output where
  dataFields   : List String
  entities     : List String
  entityTypes  : List String
  relationshipTypes : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.dataFields = i.dataFields ∧
                     o.entities = i.entities ∧
                     o.entityTypes = i.entityTypes ∧
                     o.relationshipTypes = i.relationshipTypes

example : Spec.pre { dataFields := ["symptoms", "location", "date"],
                     entities := ["patient", "hospital"],
                     entityTypes := ["person", "facility"],
                     relationshipTypes := ["treats"] } ∧
          Spec.post { dataFields := ["symptoms", "location", "date"],
                      entities := ["patient", "hospital"],
                      entityTypes := ["person", "facility"],
                      relationshipTypes := ["treats"] }
                    { dataFields := ["symptoms", "location", "date"],
                      entities := ["patient", "hospital"],
                      entityTypes := ["person", "facility"],
                      relationshipTypes := ["treats"] } := by
  unfold Spec; decide
