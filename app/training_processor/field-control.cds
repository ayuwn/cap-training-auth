using TrainingService from '../../srv/training-service';
using {sap.fe.cap.training.TrainingStatus} from '../../db/schema';

extend TrainingStatus with {
  fieldControl : Int16 @odata.Type: 'Edm.Byte' enum {
    Inapplicable = 0;
    ReadOnly = 1;
    Optional = 3;
    Mandatory = 7;
  } = (code = #Accepted ? #ReadOnly : code = #Rejected ? #ReadOnly : #Mandatory);
}

annotate TrainingService.TrainingRequest {
  BeginDate    @Common.FieldControl: TrainingStatus.fieldControl;
  EndDate      @Common.FieldControl: TrainingStatus.fieldControl;
  Provider     @Common.FieldControl: TrainingStatus.fieldControl;
  Description  @Common.FieldControl: TrainingStatus.fieldControl;
  EstCost      @Common.FieldControl: TrainingStatus.fieldControl;
  CurrencyCode @Common.FieldControl: TrainingStatus.fieldControl;
  to_Employee  @Common.FieldControl: TrainingStatus.fieldControl;
  to_Training  @Common.FieldControl: TrainingStatus.fieldControl;
}

annotate TrainingService.TrainingRequest actions {
  acceptTrainingRequest @(
    Core.OperationAvailable            : ($self.TrainingStatus.code = #Submitted),
    Common.SideEffects.TargetProperties: ['TrainingStatus_code']
  );

  rejectTrainingRequest @(
    Core.OperationAvailable            : ($self.TrainingStatus.code = #Submitted),
    Common.SideEffects.TargetProperties: ['TrainingStatus_code']
  );
}
