package com.sap.cap.training.processor;

import java.time.LocalDate;

import org.springframework.stereotype.Component;

import com.sap.cds.ql.Select;
import com.sap.cds.services.cds.CqnService;
import com.sap.cds.services.draft.DraftService;
import com.sap.cds.services.handler.EventHandler;
import com.sap.cds.services.handler.annotations.Before;
import com.sap.cds.services.handler.annotations.On;
import com.sap.cds.services.handler.annotations.ServiceName;
import com.sap.cds.services.persistence.PersistenceService;

import cds.gen.trainingservice.TrainingRequest;
import cds.gen.trainingservice.TrainingRequest_;
import cds.gen.trainingservice.TrainingService_;

@Component
@ServiceName(TrainingService_.CDS_NAME)
public class TrainingRequestHandler implements EventHandler {

    private static final String MAX_ID = "maxId";

    private final PersistenceService db;

    public TrainingRequestHandler(PersistenceService db) {
        this.db = db;
    }

    @Before(event = DraftService.EVENT_DRAFT_NEW, entity = TrainingRequest_.CDS_NAME)
    public void initialTrainingRequestId(TrainingRequest request) {
        request.trainingRequestID(0);
        request.trainingStatusCode("O");
    }

    @Before(event = CqnService.EVENT_CREATE, entity = TrainingRequest_.CDS_NAME)
    public void calculateTrainingRequestId(final TrainingRequest request) {

        if (request.trainingRequestID() == null || request.trainingRequestID() == 0) {

            Select<TrainingRequest_> maxIdSelect
                    = Select.from(TrainingService_.TRAINING_REQUEST)
                            .columns(e -> e.TrainingRequestID().max().as(MAX_ID));

            Integer currentMaxId = (Integer) db.run(maxIdSelect)
                    .first()
                    .map(row -> row.get(MAX_ID))
                    .orElse(0);

            request.trainingRequestID(++currentMaxId);
        }

        if (request.trainingStatusCode() == null) {
            request.trainingStatusCode("O");
        }
    }

    @Before(event = {
        CqnService.EVENT_CREATE,
        CqnService.EVENT_UPDATE
    }, entity = TrainingRequest_.CDS_NAME)
    public void validateTrainingDate(final TrainingRequest request) {

        if (request.beginDate() != null && request.endDate() != null) {

            if (request.beginDate().isAfter(request.endDate())) {
                throw new RuntimeException("End Date must be after Begin Date");
            }

            if (request.beginDate().isBefore(LocalDate.now())) {
                throw new RuntimeException("Begin Date must not be before today");
            }
        }
    }

    @On(event = "acceptTrainingRequest", entity = TrainingRequest_.CDS_NAME)
    public void acceptTrainingRequest(TrainingRequest request) {
        request.trainingStatusCode("A");
    }

    @On(event = "rejectTrainingRequest", entity = TrainingRequest_.CDS_NAME)
    public void rejectTrainingRequest(TrainingRequest request) {
        request.trainingStatusCode("X");
    }
}
