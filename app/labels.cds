using {sap.fe.cap.training as schema} from '../db/schema';

//
// annotations that control rendering of fields and labels
//

annotate schema.TrainingRequest with @title: 'Training' {
  TrainingRequestUUID @UI.Hidden;
  TrainingRequestID   @title               : 'Training ID';
  BeginDate           @title               : 'Date';
  EndDate             @title               : 'End Date';
  Description         @title               : 'Training Description';
  Provider            @title               : 'Provider';
  EstCost             @title: 'Estimated Cost'  @Measures.ISOCurrency : (CurrencyCode.code);
  TrainingStatus      @title: 'Status'          @Common.Text          : TrainingStatus.name  @Common.TextArrangement: #TextOnly;
  to_Employee         @title: 'Employee'        @Common.Text          : to_Employee.LastName;
  to_Training         @title: 'Training'        @Common.Text          : to_Training.TrainingName;
  createdAt           @title: 'Created On'      @Common.IsCalendarDate: true;
}

// annotate schema.TrainingStatus with {
//   code  @Common.Text: name  @Common.TextArrangement: #TextOnly
// }

annotate schema.Employee with @title: 'Employee' {
  EmployeeID     @title: 'Employee'  @Common.Text: LastName;
  FirstName      @title             : 'First Name';
  LastName       @title             : 'Last Name';
  DepartmentID   @title             : 'Department ID';
  DepartmentName @title             : 'Department Name';
  PositionID     @title             : 'Position ID';
  PositionName   @title             : 'Position Name';
}

annotate schema.Training with @title: 'Training' {
  TrainingID   @title: 'Training'  @Common.Text: TrainingName;
  TrainingName @title               : 'Training Name';
}
