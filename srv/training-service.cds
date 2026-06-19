// using {sap.fe.cap.training as my} from '../db/schema';

// service TrainingService @(path: '/processor') {
//     @(restrict: [
//         {
//             grant: 'READ',
//             to   : 'authenticated-user'
//         },
//         {
//             grant: [
//                 'rejectTraining',
//                 'acceptTraining'
//             ],
//             to   : 'reviewer'
//         },
//         {
//             grant: ['*'],
//             to   : 'processor'
//         },
//         {
//             grant: ['*'],
//             to   : 'admin'
//         }
//     ])

//     entity TrainingRequest as projection on my.TrainingRequest
//         actions {
//             action createTrainingByTemplate() returns TrainingRequest;
//             action rejectTrainingRequest();
//             action acceptTrainingRequest();
//         };

//     @readonly
//     entity Training        as projection on my.Training;

//     @readonly
//     entity Employee        as projection on my.Employee;
// }

using {sap.fe.cap.training as my} from '../db/schema';

service TrainingService @(path: '/processor') {

    @odata.draft.enabled

    entity TrainingRequest as projection on my.TrainingRequest
        actions {
            action rejectTrainingRequest();
            action acceptTrainingRequest();
        };

    @readonly
    entity Training        as projection on my.Training;

    @readonly
    entity Employee        as projection on my.Employee;
}
