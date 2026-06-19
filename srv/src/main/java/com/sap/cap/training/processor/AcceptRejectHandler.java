package com.sap.cap.training.processor;

import static cds.gen.trainingservice.TrainingService_.TRAINING_REQUEST;

import java.util.Optional;

import org.springframework.stereotype.Component;

import com.sap.cds.ql.Select;
import com.sap.cds.ql.Update;
import com.sap.cds.ql.cqn.CqnSelect;
import com.sap.cds.ql.cqn.CqnUpdate;
import com.sap.cds.services.ErrorStatuses;
import com.sap.cds.services.ServiceException;
import com.sap.cds.services.draft.DraftService;
import com.sap.cds.services.handler.EventHandler;
import com.sap.cds.services.handler.annotations.Before;
import com.sap.cds.services.handler.annotations.On;
import com.sap.cds.services.handler.annotations.ServiceName;
import com.sap.cds.services.persistence.PersistenceService;
import com.sap.cds.services.request.UserInfo;

import cds.gen.trainingservice.TrainingRequest;
import cds.gen.trainingservice.TrainingRequest_;
import cds.gen.trainingservice.TrainingRequestAcceptTrainingRequestContext;
import cds.gen.trainingservice.TrainingRequestRejectTrainingRequestContext;
import cds.gen.trainingservice.TrainingService_;

@Component
@ServiceName(TrainingService_.CDS_NAME)
public class AcceptRejectHandler implements EventHandler {

    private static final String TRAINING_STATUS_OPEN = "O";
    private static final String TRAINING_STATUS_ACCEPTED = "A";
    private static final String TRAINING_STATUS_REJECTED = "X";

    private final PersistenceService persistenceService;
    private final DraftService draftService;

    public AcceptRejectHandler(
            DraftService draftService,
            PersistenceService persistenceService) {
        this.draftService = draftService;
        this.persistenceService = persistenceService;
    }

    @Before(entity = TrainingRequest_.CDS_NAME)
    public void beforeAcceptTrainingRequest(
            final TrainingRequestAcceptTrainingRequestContext context) {
        beforeAcceptOrRejectTrainingRequest(
                context.cqn(),
                context.getUserInfo());
    }

    @Before(entity = TrainingRequest_.CDS_NAME)
    public void beforeRejectTrainingRequest(
            final TrainingRequestRejectTrainingRequestContext context) {
        beforeAcceptOrRejectTrainingRequest(
                context.cqn(),
                context.getUserInfo());
    }

    private void beforeAcceptOrRejectTrainingRequest(
            CqnSelect select,
            UserInfo userInfo) {

        Optional<TrainingRequest> requestToProcess
                = draftService.run(
                        Select.from(TrainingRequest_.class)
                                .where(select.from()
                                        .asRef()
                                        .targetSegment()
                                        .filter()
                                        .get())
                                .columns(
                                        t -> t.DraftAdministrativeData()
                                                .expand(d -> d.InProcessByUser()),
                                        t -> t.TrainingStatus_code(),
                                        t -> t.IsActiveEntity(),
                                        t -> t.TrainingRequestID()
                                ))
                        .first(TrainingRequest.class);

        requestToProcess.ifPresent(request -> {
            checkIfTrainingRequestHasExpectedStatus(request);
            checkIfTrainingRequestIsLockedByAnotherUser(request, userInfo);
        });
    }

    @On(entity = TrainingRequest_.CDS_NAME)
    public void onAcceptTrainingRequest(
            final TrainingRequestAcceptTrainingRequestContext context) {

        TrainingRequest request
                = draftService.run(context.cqn()).single(TrainingRequest.class);

        context.getCdsRuntime()
                .requestContext()
                .privilegedUser()
                .run(ctx -> {
                    updateStatusForTrainingRequest(
                            request.trainingRequestUUID(),
                            TRAINING_STATUS_ACCEPTED,
                            request.isActiveEntity());
                });

        context.setCompleted();
    }

    @On(entity = TrainingRequest_.CDS_NAME)
    public void onRejectTrainingRequest(
            final TrainingRequestRejectTrainingRequestContext context) {

        TrainingRequest request
                = draftService.run(context.cqn()).single(TrainingRequest.class);

        context.getCdsRuntime()
                .requestContext()
                .privilegedUser()
                .run(ctx -> {
                    updateStatusForTrainingRequest(
                            request.trainingRequestUUID(),
                            TRAINING_STATUS_REJECTED,
                            request.isActiveEntity());
                });

        context.setCompleted();
    }

    private void updateStatusForTrainingRequest(
            String trainingRequestUUID,
            String newStatus,
            boolean isActiveEntity) {

        if (isActiveEntity) {
            persistenceService.run(
                    Update.entity(TRAINING_REQUEST)
                            .where(t -> t.TrainingRequestUUID()
                            .eq(trainingRequestUUID))
                            .data(TrainingRequest.TRAINING_STATUS_CODE, newStatus));
        } else {
            CqnUpdate updateDraft
                    = Update.entity(TRAINING_REQUEST)
                            .where(t -> t.TrainingRequestUUID()
                            .eq(trainingRequestUUID)
                            .and(t.IsActiveEntity().eq(false)))
                            .data(TrainingRequest.TRAINING_STATUS_CODE, newStatus);

            draftService.patchDraft(updateDraft).first(TrainingRequest.class);
        }
    }

    private void checkIfTrainingRequestHasExpectedStatus(
            TrainingRequest request) {

        if (request.trainingStatusCode() != null
                && !request.trainingStatusCode()
                        .equalsIgnoreCase(TRAINING_STATUS_OPEN)) {

            throw new ServiceException(
                    ErrorStatuses.BAD_REQUEST,
                    String.format(
                            "Training Request %s cannot be processed because status is %s. Expected status is %s.",
                            request.trainingRequestID(),
                            request.trainingStatusCode(),
                            TRAINING_STATUS_OPEN));
        }
    }

    private void checkIfTrainingRequestIsLockedByAnotherUser(
            TrainingRequest request,
            UserInfo userInfo) {

        if (!request.isActiveEntity()
                && request.draftAdministrativeData() != null
                && request.draftAdministrativeData().inProcessByUser() != null
                && !request.draftAdministrativeData()
                        .inProcessByUser()
                        .equals(userInfo.getName())) {

            throw new ServiceException(
                    ErrorStatuses.UNAUTHORIZED,
                    String.format(
                            "The draft is locked by %s.",
                            request.draftAdministrativeData().inProcessByUser()));
        }

        if (request.isActiveEntity()
                && request.draftAdministrativeData() != null
                && request.draftAdministrativeData().inProcessByUser() != null) {

            throw new ServiceException(
                    ErrorStatuses.UNAUTHORIZED,
                    String.format(
                            "The draft is locked by %s.",
                            request.draftAdministrativeData().inProcessByUser()));
        }
    }
}
