using {
    Currency,
    custom.managed,
    sap
} from './common';

namespace sap.fe.cap.training;

// ensure all masterdata entities are available to clients
@cds.autoexpose  @readonly
aspect MasterData {}

entity Training : MasterData {
    key TrainingID   : String(8);
        TrainingName : String(100);
};

entity Employee : managed, MasterData {
    key EmployeeID     : String(8);
        FirstName      : String(40);
        LastName       : String(40);
        DepartmentID   : String(8);
        DepartmentName : String(100);
        PositionID     : String(8);
        PositionName   : String(100);
}
