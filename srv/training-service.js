const cds = require("@sap/cds");

module.exports = class TrainingService extends cds.ApplicationService {
    async init() {
        const { TrainingRequest } = this.entities;

        async function getNextId() {
            const active = await SELECT.one`max(TrainingRequestID) as maxID`
                .from(TrainingRequest);

            const draft = await SELECT.one`max(TrainingRequestID) as maxID`
                .from(TrainingRequest.drafts);

            const maxActive = active?.maxID || 0;
            const maxDraft = draft?.maxID || 0;

            return Math.max(maxActive, maxDraft) + 1;
        }

        function hasRole(req, role) {
            const roles = req.http?.req?.firebaseUser?.roles || [];

            console.log("CURRENT FIREBASE USER:", req.http?.req?.firebaseUser);
            console.log("CHECK ROLE:", role, roles);

            return roles.includes(role);
        }

        this.before("NEW", TrainingRequest.drafts, async (req) => {
            if (!hasRole(req, "admin")) {
                return req.reject(403, "Only admin can create training request");
            }

            req.data.TrainingRequestID = await getNextId();
        });

        this.before("CREATE", TrainingRequest, async (req) => {
            if (!hasRole(req, "admin")) {
                return req.reject(403, "Only admin can create training request");
            }

            if (!req.data.TrainingRequestID || req.data.TrainingRequestID === 0) {
                req.data.TrainingRequestID = await getNextId();
            }
        });

        this.on("acceptTrainingRequest", TrainingRequest, async (req) => {
            if (!hasRole(req, "approver")) {
                return req.reject(403, "Only supervisor can approve training request");
            }

            const trainingRequestUUID = req.params[0].TrainingRequestUUID;

            await UPDATE(TrainingRequest)
                .set({ TrainingStatus_code: "A" })
                .where({ TrainingRequestUUID: trainingRequestUUID });

            return {};
        });

        this.on("rejectTrainingRequest", TrainingRequest, async (req) => {
            if (!hasRole(req, "approver")) {
                return req.reject(403, "Only supervisor can reject training request");
            }

            const trainingRequestUUID = req.params[0].TrainingRequestUUID;

            await UPDATE(TrainingRequest)
                .set({ TrainingStatus_code: "X" })
                .where({ TrainingRequestUUID: trainingRequestUUID });

            return {};
        });

        return super.init();
    }
};
