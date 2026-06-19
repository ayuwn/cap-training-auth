require("dotenv").config({ path: require("path").join(__dirname, "../.env") });

const cds = require("@sap/cds");
const admin = require("firebase-admin");
const cookieParser = require("cookie-parser");
const path = require("path");

admin.initializeApp({
    credential: admin.credential.cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n")
    })
});

cds.on("bootstrap", app => {
    app.use(cookieParser());
    app.use(require("express").json());

    app.get("/", (req, res) => {
        res.sendFile(path.join(__dirname, "../app/index.html"));
    });

    app.post("/sessionLogin", async (req, res) => {
        const { idToken } = req.body;

        if (!idToken) {
            return res.status(400).send("Missing ID token");
        }

        try {
            const expiresIn = 60 * 60 * 24 * 5 * 1000;

            const sessionCookie = await admin
                .auth()
                .createSessionCookie(idToken, { expiresIn });

            res.cookie("session", sessionCookie, {
                maxAge: expiresIn,
                httpOnly: true,
                secure: false,
                sameSite: "lax"
            });

            return res.status(200).send({ status: "success" });
        } catch (error) {
            return res.status(401).send("Unauthorized");
        }
    });

    app.get("/logout", (req, res) => {
        res.clearCookie("session");
        res.redirect("/");
    });

    app.use(async (req, res, next) => {
        const publicPath =
            req.path === "/" ||
            req.path === "/sessionLogin" ||
            req.path === "/logout" ||
            req.path.startsWith("/resources") ||
            req.path.startsWith("/test-resources");

        if (publicPath) {
            return next();
        }

        const sessionCookie = req.cookies.session;

        if (!sessionCookie) {
            return res.redirect("/");
        }

        try {
            const decoded = await admin
                .auth()
                .verifySessionCookie(sessionCookie, true);

            const roles = [];

            if (decoded.email === "admin@training.com") {
                roles.push("admin");
            }

            if (decoded.email === "supervisor@training.com") {
                roles.push("approver");
            }

            req.firebaseUser = {
                uid: decoded.uid,
                email: decoded.email,
                roles
            };

            next();
        } catch (error) {
            res.clearCookie("session");
            return res.redirect("/");
        }
    });
});

module.exports = cds.server;