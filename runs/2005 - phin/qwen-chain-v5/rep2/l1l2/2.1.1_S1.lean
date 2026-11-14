import ContractForge
open ContractForge

-- 2.1.1/S1: Systems designed to support OM must offer configuration flexibility so that new data fields, entities, entity types and relationship types may be added to capture information unique to each particular health event.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { dataFields := x.dataFields,
    entities := x.entities,
    entityTypes := x.entityTypes,
    relationshipTypes := x.relationshipTypes }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
