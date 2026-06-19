using {sap.fe.cap.training as db} from '../db/schema';

service AnalyticsService @(path: '/analytics') {

  @readonly
  @cds.localized: false
  entity TrainingRequests as
    projection on db.TrainingRequest {
      key TrainingRequestUUID,

          1                          as RequestCount : Integer,

          TrainingRequestID,
          BeginDate,
          EndDate,
          Provider,
          EstCost,

          CurrencyCode.code          as CurrencyCode,

          TrainingStatus.code        as StatusCode,
          TrainingStatus.name        as StatusName,

          to_Employee.EmployeeID     as EmployeeID,
          to_Employee.FirstName      as EmployeeFirstName,
          to_Employee.LastName       as EmployeeLastName,
          to_Employee.DepartmentID   as DepartmentID,
          to_Employee.DepartmentName as DepartmentName,
          to_Employee.PositionID     as PositionID,
          to_Employee.PositionName   as PositionName,

          to_Training.TrainingID     as TrainingID,
          to_Training.TrainingName   as TrainingName,

          createdAt
    };

  @readonly
  entity Employee         as projection on db.Employee;

  @readonly
  entity Training         as projection on db.Training;

  @readonly
  entity TrainingStatus   as projection on db.TrainingStatus;
}
