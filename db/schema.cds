using {
    Currency,
    custom.managed,
    sap.common.CodeList
} from './common';
using {
    sap.fe.cap.training.Training,
    sap.fe.cap.training.Employee
} from './master-data';

namespace sap.fe.cap.training;

entity TrainingRequest : managed {
    key TrainingRequestUUID : UUID;
        TrainingRequestID   : Integer default 0                         @readonly;
        BeginDate           : Date                                      @mandatory;
        EndDate             : Date                                      @mandatory;
        Provider            : String(100);
        Description         : String(1024);
        EstCost             : Decimal(16, 3) default 0;
        CurrencyCode        : Currency default 'IDR';
        TrainingStatus      : Association to TrainingStatus default 'O' @readonly;
        to_Employee         : Association to Employee                   @mandatory;
        to_Training         : Association to Training                   @mandatory;
}

annotate TrainingRequest with @Capabilities.FilterRestrictions.FilterExpressionRestrictions: [
    {
        Property          : 'BeginDate',
        AllowedExpressions: 'SingleRange'
    },
    {
        Property          : 'EndDate',
        AllowedExpressions: 'SingleRange'
    }
];


// code list

type TrainingStatusCode : String(1) enum {
    Submitted = 'O';
    Accepted = 'A';
    Rejected = 'X';
}

entity TrainingStatus : CodeList {
    key code : TrainingStatusCode;
}
