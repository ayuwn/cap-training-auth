sap.ui.define([
    "sap/ui/core/mvc/ControllerExtension"
], function (ControllerExtension) {
    "use strict";

    return ControllerExtension.extend(
        "sap.fe.cap.training.ext.controller.ListReportExt",
        {
            override: {
                onAfterRendering: function () {
                    this._hideDraftEditStateFilter();
                }
            },

            _hideDraftEditStateFilter: function () {
                const oView = this.base.getView();

                setTimeout(function () {
                    const aControls = oView.findAggregatedObjects(true, function (oControl) {
                        return (
                            oControl &&
                            oControl.getVisible &&
                            (
                                oControl.isA("sap.ui.mdc.FilterField") ||
                                oControl.isA("sap.m.Label") ||
                                oControl.isA("sap.m.ComboBox") ||
                                oControl.isA("sap.m.Select")
                            )
                        );
                    });

                    aControls.forEach(function (oControl) {
                        let sText = "";

                        if (oControl.getLabel) {
                            sText = oControl.getLabel();
                        }

                        if (!sText && oControl.getText) {
                            sText = oControl.getText();
                        }

                        if (!sText && oControl.getPropertyKey) {
                            sText = oControl.getPropertyKey();
                        }

                        sText = String(sText || "").toLowerCase();

                        if (
                            sText.includes("editing status") ||
                            sText.includes("status pengeditan") ||
                            sText.includes("draft")
                        ) {
                            oControl.setVisible(false);
                        }
                    });
                }, 500);
            }
        }
    );
});