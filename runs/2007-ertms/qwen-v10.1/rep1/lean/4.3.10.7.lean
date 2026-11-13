import ContractForge
open ContractForge

-- 4.3.10.7: The following information shall be recorded: any transition of Level and of operational status the driver's confirmation of transition to shunting train supervision data and information received from national train control systems actual speed full service brake intervention emergency brake intervention applying the train trip function selection of the override control override of the route suitability function isolation of on board ETCS equipmen data entered, recieved or indicated to the driver
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  level : Nat
  operational_status : String
  shunting_confirmation : Bool
  shunting_data : Bool
  national_train_control_data : Bool
  actual_speed : Nat
  full_service_brake : Bool
  emergency_brake : Bool
  train_trip_function : Bool
  override_control : Bool
  route_suitability_function : Bool
  isolation_of_ets : Bool
  data_entered : String
  data_received : String
  data_indicated : String
  deriving DecidableEq, Repr

structure Output where
  level : Nat
  operational_status : String
  shunting_confirmation : Bool
  shunting_data : Bool
  national_train_control_data : Bool
  actual_speed : Nat
  full_service_brake : Bool
  emergency_brake : Bool
  train_trip_function : Bool
  override_control : Bool
  route_suitability_function : Bool
  isolation_of_ets : Bool
  data_entered : String
  data_received : String
  data_indicated : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => 
    o.level = i.level ∧
    o.operational_status = i.operational_status ∧
    o.shunting_confirmation = i.shunting_confirmation ∧
    o.shunting_data = i.shunting_data ∧
    o.national_train_control_data = i.national_train_control_data ∧
    o.actual_speed = i.actual_speed ∧
    o.full_service_brake = i.full_service_brake ∧
    o.emergency_brake = i.emergency_brake ∧
    o.train_trip_function = i.train_trip_function ∧
    o.override_control = i.override_control ∧
    o.route_suitability_function = i.route_suitability_function ∧
    o.isolation_of_ets = i.isolation_of_ets ∧
    o.data_entered = i.data_entered ∧
    o.data_received = i.data_received ∧
    o.data_indicated = i.data_indicated

example : Spec.pre { level := 1, operational_status := "normal", shunting_confirmation := false,
                     shunting_data := false, national_train_control_data := false,
                     actual_speed := 50, full_service_brake := false, emergency_brake := false,
                     train_trip_function := false, override_control := false,
                     route_suitability_function := false, isolation_of_ets := false,
                     data_entered := "data1", data_received := "data2", data_indicated := "data3" } ∧
          Spec.post { level := 1, operational_status := "normal", shunting_confirmation := false,
                      shunting_data := false, national_train_control_data := false,
                      actual_speed := 50, full_service_brake := false, emergency_brake := false,
                      train_trip_function := false, override_control := false,
                      route_suitability_function := false, isolation_of_ets := false,
                      data_entered := "data1", data_received := "data2", data_indicated := "data3" }
                    { level := 1, operational_status := "normal", shunting_confirmation := false,
                      shunting_data := false, national_train_control_data := false,
                      actual_speed := 50, full_service_brake := false, emergency_brake := false,
                      train_trip_function := false, override_control := false,
                      route_suitability_function := false, isolation_of_ets := false,
                      data_entered := "data1", data_received := "data2", data_indicated := "data3" } := by
  unfold Spec; decide
