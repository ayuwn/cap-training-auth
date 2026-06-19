using TrainingService from '../srv/training-service';

annotate TrainingService.TrainingRequest {

  TrainingStatus @Common.ValueListWithFixedValues;

  to_Training    @(
    Common.Text           : to_Training.TrainingName,
    Common.TextArrangement: #TextLast,
    Common.ValueList      : {
      CollectionPath: 'Training',
      Label         : 'Training',
      Parameters    : [
        {
          $Type            : 'Common.ValueListParameterInOut',
          LocalDataProperty: to_Training_TrainingID,
          ValueListProperty: 'TrainingID'
        },
        {
          $Type            : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'TrainingName'
        }
      ]
    }
  );

  to_Employee    @(
    Common.Text           : to_Employee.FirstName,
    Common.TextArrangement: #TextLast,
    Common.ValueList      : {
      CollectionPath: 'Employee',
      Label         : 'Employee',
      Parameters    : [
        {
          $Type            : 'Common.ValueListParameterInOut',
          LocalDataProperty: to_Employee_EmployeeID,
          ValueListProperty: 'EmployeeID'
        },
        {
          $Type            : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'FirstName'
        },
        {
          $Type            : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'LastName'
        },
        {
          $Type            : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'DepartmentID'
        },
        {
          $Type            : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'DepartmentName'
        },
        {
          $Type            : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'PositionID'
        },
        {
          $Type            : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'PositionName'
        }
      ]
    }
  );

  // CurrencyCode   @Common.ValueList: {
  //   CollectionPath: 'Currencies',
  //   Label         : 'Currency',
  //   Parameters    : [
  //     {
  //       $Type            : 'Common.ValueListParameterInOut',
  //       LocalDataProperty: CurrencyCode_code,
  //       ValueListProperty: 'code'
  //     },
  //     {
  //       $Type            : 'Common.ValueListParameterDisplayOnly',
  //       ValueListProperty: 'name'
  //     }
  //   ]
  // };

  CurrencyCode   @Common.ValueList: {
    CollectionPath: 'Currencies',
    Label         : 'Currency',
    Parameters    : [
      {
        $Type            : 'Common.ValueListParameterInOut',
        LocalDataProperty: CurrencyCode_code,
        ValueListProperty: 'code'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'name'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'descr'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'symbol'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'minor'
      }
    ]
  };
}
