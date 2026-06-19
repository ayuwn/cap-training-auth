using TrainingService from '../../srv/training-service';

annotate TrainingService.TrainingRequest with @Common.SideEffects: {
  SourceProperties: ['to_Employee_EmployeeID'],
  TargetProperties: [
    'to_Employee/FirstName',
    'to_Employee/LastName',
    'to_Employee/DepartmentID',
    'to_Employee/DepartmentName',
    'to_Employee/PositionID',
    'to_Employee/PositionName'
  ]
};

annotate TrainingService.TrainingRequest with @UI : {

  Identification                 : [
    {
      $Type : 'UI.DataFieldForAction',
      Action: 'TrainingService.acceptTrainingRequest',
      Label : 'Approve'
    },
    {
      $Type : 'UI.DataFieldForAction',
      Action: 'TrainingService.rejectTrainingRequest',
      Label : 'Reject'
    }
  ],

  HeaderInfo                     : {
    TypeName      : 'Training Request',
    TypeNamePlural: 'Training Requests',
    Title         : {
      $Type: 'UI.DataField',
      Value: to_Training.TrainingName,
      Label: 'Training'
    },
    Description   : {
      $Type: 'UI.DataField',
      Value: TrainingRequestID,
      Label: 'Training ID'
    }
  },

  PresentationVariant            : {
    Text          : 'Default',
    Visualizations: ['@UI.LineItem'],
    SortOrder     : [{
      $Type     : 'Common.SortOrderType',
      Property  : TrainingRequestID,
      Descending: true
    }]
  },

  SelectionFields                : [
    TrainingStatus_code,
    to_Employee_EmployeeID,
    to_Training_TrainingID,
    BeginDate
  ],

  LineItem                       : [
    {
      $Type : 'UI.DataFieldForAction',
      Action: 'TrainingService.acceptTrainingRequest',
      Label : 'Approve'
    },
    {
      $Type : 'UI.DataFieldForAction',
      Action: 'TrainingService.rejectTrainingRequest',
      Label : 'Reject'
    },
    {
      Value             : TrainingRequestID,
      @UI.Importance    : #High,
      @HTML5.CssDefaults: {width: '8em'}
    },
    {
      Value             : (to_Employee.EmployeeID),
      @UI.Importance    : #High,
      @HTML5.CssDefaults: {width: '12em'}
    },
    {
      Value             : (to_Training.TrainingID),
      @UI.Importance    : #High,
      @HTML5.CssDefaults: {width: '15em'}
    },
    {
      Value             : Provider,
      @UI.Importance    : #High,
      @HTML5.CssDefaults: {width: '10em'}
    },
    {
      Value             : BeginDate,
      Label             : 'Start Date',
      @UI.Importance    : #High,
      @HTML5.CssDefaults: {width: '7em'}
    },
    {
      Value             : EndDate,
      @UI.Importance    : #High,
      @HTML5.CssDefaults: {width: '7em'}
    },
    {
      Value             : EstCost,
      @UI.Importance    : #High,
      @HTML5.CssDefaults: {width: '12em'}
    },
    {
      Value                    : (TrainingStatus.code),
      Criticality              : (TrainingStatus.code = #Submitted ? 5 : (TrainingStatus.code = #Accepted ? 3 : 1)),
      CriticalityRepresentation: #WithoutIcon,
      @UI.Importance           : #High,
      @HTML5.CssDefaults       : {width: '7em'}
    },
    {
      Value             : createdAt,
      @UI.Importance    : #High,
      @HTML5.CssDefaults: {width: '7em'}
    },
  ],

  Facets                         : [{
    $Type : 'UI.CollectionFacet',
    ID    : 'GeneralInformation',
    Label : 'General Information',
    Facets: [
      {
        $Type : 'UI.ReferenceFacet',
        ID    : 'EmployeeInformation',
        Label : 'Employee Information',
        Target: '@UI.FieldGroup#EmployeeInformation'
      },
      {
        $Type : 'UI.ReferenceFacet',
        ID    : 'TrainingInformation',
        Label : 'Training Information',
        Target: '@UI.FieldGroup#TrainingInformation'
      },
      {
        $Type : 'UI.ReferenceFacet',
        ID    : 'TrainingPeriod',
        Label : 'Training Period',
        Target: '@UI.FieldGroup#TrainingPeriod'
      }
    ]
  }],

  FieldGroup #EmployeeInformation: {Data: [
    {Value: to_Employee_EmployeeID},
    {Value: (to_Employee.FirstName)},
    {Value: (to_Employee.LastName)},
    {Value: (to_Employee.DepartmentID)},
    {Value: (to_Employee.DepartmentName)},
    {Value: (to_Employee.PositionID)},
    {Value: (to_Employee.PositionName)}
  ]},

  FieldGroup #TrainingInformation: {Data: [
    {Value: (to_Training.TrainingID)},
    {Value: Provider},
    {Value: Description}
  ]},

  FieldGroup #TrainingPeriod     : {Data: [
    {Value: BeginDate},
    {Value: EndDate},
    {Value: EstCost}
  // {
  //   Value: TrainingStatus.code,
  //   Label: 'Status'
  // }
  ]}
};
