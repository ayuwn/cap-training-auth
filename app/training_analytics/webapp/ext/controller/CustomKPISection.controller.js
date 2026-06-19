sap.ui.define([
    "sap/ui/core/mvc/ControllerExtension",
    "sap/ui/core/Fragment",
    "sap/ui/model/json/JSONModel"
], function (ControllerExtension, Fragment, JSONModel) {
    "use strict";

    return ControllerExtension.extend(
        "sap.fe.cap.training_analytics.ext.controller.CustomKPISection",
        {
            override: {
                onInit: function () {
                    const oView = this.base.getView();

                    oView.setModel(new JSONModel({
                        totalRequests: 0,
                        submitted: 0,
                        approved: 0,
                        rejected: 0,
                        draft: 0,
                        totalCost: "0"
                    }), "kpi");

                    oView.setModel(new JSONModel({
                        statusData: [],
                        requestByDepartment: [],
                        costByTraining: [],
                        requestsByMonth: []
                    }), "analytics");

                    this._loadKpiData();
                    this._loadAnalyticsData();
                },

                onAfterRendering: function () {
                    this._insertCustomSections();
                }
            },

            _insertCustomSections: async function () {
                if (this._bInserted) {
                    return;
                }

                const oView = this.base.getView();

                const oKpiFragment = await Fragment.load({
                    id: oView.getId(),
                    name: "sap.fe.cap.training_analytics.ext.fragment.CustomKPISection",
                    controller: this
                });

                const oAnalyticsFragment = await Fragment.load({
                    id: oView.getId(),
                    name: "sap.fe.cap.training_analytics.ext.fragment.CustomAnalyticsSection",
                    controller: this
                });

                const aDynamicPages = oView.findAggregatedObjects(true, function (oControl) {
                    return oControl.isA && oControl.isA("sap.f.DynamicPage");
                });

                const oDynamicPage = aDynamicPages && aDynamicPages[0];

                if (!oDynamicPage) {
                    return;
                }

                const oContent = oDynamicPage.getContent();

                const oWrapper = new sap.m.VBox({
                    width: "100%",
                    items: [
                        oKpiFragment,
                        oAnalyticsFragment,
                        oContent
                    ]
                });

                oDynamicPage.setContent(oWrapper);

                this._setChartProperties();

                this._bInserted = true;
            },

            _loadKpiData: async function () {
                const oModel = this.base.getView().getModel("kpi");

                try {
                    const res = await fetch(
                        "/processor/TrainingRequest?$select=TrainingStatus_code,EstCost,IsActiveEntity"
                    );

                    const data = await res.json();
                    const rows = data.value || [];

                    let submitted = 0;
                    let approved = 0;
                    let rejected = 0;
                    let draft = 0;
                    let totalCost = 0;

                    rows.forEach(function (row) {
                        if (row.IsActiveEntity === false) {
                            draft++;
                        }

                        if (row.TrainingStatus_code === "O") {
                            submitted++;
                        }

                        if (row.TrainingStatus_code === "A") {
                            approved++;
                        }

                        if (row.TrainingStatus_code === "X") {
                            rejected++;
                        }

                        totalCost += Number(row.EstCost || 0);
                    });

                    oModel.setData({
                        totalRequests: rows.length,
                        submitted: submitted,
                        approved: approved,
                        rejected: rejected,
                        draft: draft,
                        // totalCost: new Intl.NumberFormat("id-ID").format(totalCost)
                        totalCost: new Intl.NumberFormat("id-ID", {
                            minimumFractionDigits: 2,
                            maximumFractionDigits: 2
                        }).format(totalCost)
                    });
                } catch (error) {
                    console.error("Failed to load KPI data:", error);
                }
            },

            _loadAnalyticsData: async function () {
                const oModel = this.base.getView().getModel("analytics");

                try {
                    const res = await fetch(
                        // "/processor/TrainingRequest?$select=BeginDate,EstCost,TrainingStatus_code,to_Training_TrainingID&$expand=to_Training($select=TrainingName)"
                        "/processor/TrainingRequest?$select=BeginDate,EstCost,TrainingStatus_code,to_Training_TrainingID,to_Employee_EmployeeID&$expand=to_Training($select=TrainingName),to_Employee($select=DepartmentName)"
                    );

                    const data = await res.json();
                    const rows = data.value || [];

                    const statusMap = {};
                    const departmentMap = {};
                    const costMap = {};
                    const monthMap = {};

                    rows.forEach(function (row) {
                        const status = this._getStatusText(row.TrainingStatus_code);
                        const departmentName =
                            row.to_Employee && row.to_Employee.DepartmentName
                                ? row.to_Employee.DepartmentName
                                : "-";

                        departmentMap[departmentName] = (departmentMap[departmentName] || 0) + 1;
                        const trainingName =
                            row.to_Training && row.to_Training.TrainingName
                                ? row.to_Training.TrainingName
                                : row.to_Training_TrainingID || "-";

                        const cost = Number(row.EstCost || 0);

                        statusMap[status] = (statusMap[status] || 0) + 1;
                        costMap[trainingName] = (costMap[trainingName] || 0) + cost;

                        if (row.BeginDate) {
                            const month = this._getMonthLabel(row.BeginDate);
                            monthMap[month.key] = monthMap[month.key] || {
                                Month: month.text,
                                MonthNumber: month.number,
                                TotalRequests: 0
                            };
                            monthMap[month.key].TotalRequests++;
                        }
                    }.bind(this));

                    const statusData = Object.keys(statusMap).map(function (key) {
                        return {
                            Status: key,
                            Count: statusMap[key]
                        };
                    });

                    const requestByDepartment = Object.keys(departmentMap)
                        .map(function (key) {
                            return {
                                DepartmentName: key,
                                TotalRequests: departmentMap[key]
                            };
                        })
                        .sort(function (a, b) {
                            return b.TotalRequests - a.TotalRequests;
                        });

                    const costByTraining = Object.keys(costMap)
                        .map(function (key) {
                            return {
                                TrainingName: key,
                                TotalCost: costMap[key]
                            };
                        })
                        .sort(function (a, b) {
                            return b.TotalCost - a.TotalCost;
                        });

                    const requestsByMonth = Object.keys(monthMap)
                        .map(function (key) {
                            return monthMap[key];
                        })
                        .sort(function (a, b) {
                            return a.MonthNumber - b.MonthNumber;
                        });

                    oModel.setData({
                        statusData: statusData,
                        requestByDepartment: requestByDepartment,
                        costByTraining: costByTraining,
                        requestsByMonth: requestsByMonth
                    });

                    this._setChartProperties();
                } catch (error) {
                    console.error("Failed to load analytics data:", error);
                }
            },

            _getStatusText: function (statusCode) {
                switch (statusCode) {
                    case "O":
                        return "Submitted";
                    case "A":
                        return "Approved";
                    case "X":
                        return "Rejected";
                    default:
                        return "Draft";
                }
            },

            _getMonthLabel: function (dateValue) {
                const date = new Date(dateValue);

                if (isNaN(date.getTime())) {
                    return {
                        key: "00",
                        number: 0,
                        text: "-"
                    };
                }

                const monthNumber = date.getMonth() + 1;

                const monthText = date.toLocaleString("en-US", {
                    month: "short"
                });

                return {
                    key: String(monthNumber).padStart(2, "0"),
                    number: monthNumber,
                    text: monthText
                };
            },

            _setChartProperties: function () {
                const oView = this.base.getView();

                const oStatusChart = oView.byId("statusChart");
                const oDepartmentChart = oView.byId("departmentChart");
                const oCostChart = oView.byId("costChart");
                const oMonthChart = oView.byId("monthChart");

                if (oStatusChart) {
                    oStatusChart.setVizProperties({
                        title: {
                            visible: false
                        },
                        legend: {
                            visible: true,
                            position: "right"
                        },
                        plotArea: {
                            dataLabel: {
                                visible: true,
                                type: "percentage"
                            }
                        }
                    });
                }

                if (oDepartmentChart) {
                    oDepartmentChart.setVizProperties({
                        title: {
                            visible: false
                        },
                        legend: {
                            visible: false
                        },
                        plotArea: {
                            dataLabel: {
                                visible: true
                            }
                        },
                        valueAxis: {
                            title: {
                                visible: false
                            }
                        },
                        categoryAxis: {
                            title: {
                                visible: false
                            }
                        }
                    });
                }

                if (oCostChart) {
                    oCostChart.setVizProperties({
                        title: {
                            visible: false
                        },
                        legend: {
                            visible: false
                        },
                        plotArea: {
                            dataLabel: {
                                visible: true
                            }
                        },
                        valueAxis: {
                            title: {
                                visible: false
                            },
                            label: {
                                formatString: "#,##0"
                            }
                        },
                        categoryAxis: {
                            title: {
                                visible: false
                            }
                        }
                    });
                }

                if (oMonthChart) {
                    oMonthChart.setVizProperties({
                        title: {
                            visible: false
                        },
                        legend: {
                            visible: false
                        },
                        plotArea: {
                            dataLabel: {
                                visible: true
                            }
                        },
                        valueAxis: {
                            title: {
                                visible: false
                            }
                        },
                        categoryAxis: {
                            title: {
                                visible: false
                            }
                        }
                    });
                }
            }
        }
    );
});