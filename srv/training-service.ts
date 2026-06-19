import cds from '@sap/cds'
import { TrainingRequest as TrainingRequest } from '#cds-models/TrainingService'
import { TrainingStatusCode } from '#cds-models/sap/fe/cap/training'
import { CdsDate } from '#cds-models/_'

export class TrainingService extends cds.ApplicationService { init() {
    // reflected definitions from the service's CDS model
    const { today } = cds.builtin.types.Date as unknown as { today(): CdsDate };

    // fill in alternative keys as consecutive numbers for new Training Request.
    // note: for Training Request that can't be done at NEW events, that is when drafts are created.
    // but on CREATE only, as multiple users could create new Training Request concurrently.

    this.before ('CREATE', TrainingRequest, async req => {
        let { maxID } = await SELECT.one (`max(TrainingRequestID) as maxID`) .from (TrainingRequest) as { maxID: number }
        req.data.TrainingRequestID = ++ maxID
    })

    this.before ('SAVE', TrainingRequest, req => {
        const { BeginDate, EndDate } = req.data
        if (BeginDate < today()) req.error (400, `Begin Date must not before today`, 'in/BeginDate')
        if (BeginDate > EndDate) req.error (400, `End Date must be after Begin Date`, 'in/EndDate')
    } )

    // action implementation

    const { acceptTrainingRequest, rejectTrainingRequest } = TrainingRequest.actions;
    this.on (acceptTrainingRequest, req => UPDATE (req.subject) .with ({ TrainingStatus_code: TrainingStatusCode.Accepted }))
    this.on (rejectTrainingRequest, req => UPDATE (req.subject) .with ({ TrainingStatus_code: TrainingStatusCode.Rejected }))

    return super.init()
}}