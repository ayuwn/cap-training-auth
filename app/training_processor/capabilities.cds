using TrainingService from '../../srv/training-service';

annotate TrainingService.TrainingRequest with @odata.draft.enabled;
annotate TrainingService.TrainingRequest with @Common.SemanticKey: [TrainingRequestID];
