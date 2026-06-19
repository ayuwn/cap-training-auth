using AnalyticsService as service from '../../srv/analytics-service';

annotate service.TrainingRequests with @(
    Aggregation.CustomAggregate #RequestCount: 'Edm.Int32',
    Aggregation.CustomAggregate #EstCost     : 'Edm.Decimal',
    Aggregation.CustomAggregate #CurrencyCode: 'Edm.String',
    Common.SemanticKey                       : [TrainingRequestUUID]
) {
    RequestCount @Aggregation.default: #SUM;
    EstCost      @Aggregation.default: #SUM;
    CurrencyCode @Aggregation.default: #MAX;
};

annotate service.TrainingRequests with @Aggregation.ApplySupported: {
    Transformations       : [
        'aggregate',
        'groupby',
        'filter',
        'search',
        'topcount',
        'bottomcount',
        'identity',
        'concat'
    ],
    GroupableProperties   : [
        TrainingRequestID,
        BeginDate,
        EndDate,
        Provider,
        CurrencyCode,
        StatusCode,
        StatusName,
        EmployeeID,
        EmployeeFirstName,
        EmployeeLastName,
        DepartmentID,
        DepartmentName,
        PositionID,
        PositionName,
        TrainingID,
        TrainingName
    ],
    AggregatableProperties: [
        {Property: RequestCount},
        {Property: EstCost}
    ]
};

annotate service.TrainingRequests with @(
    Analytics.AggregatedProperty #countRequests: {
        Name                : 'countRequests',
        AggregationMethod   : 'sum',
        AggregatableProperty: RequestCount,
        @Common.Label       : 'Total Requests'
    },
    Analytics.AggregatedProperty #totalCost    : {
        Name                : 'totalCost',
        AggregationMethod   : 'sum',
        AggregatableProperty: EstCost,
        @Common.Label       : 'Total Estimated Cost'
    },
    Analytics.AggregatedProperty #avgCost      : {
        Name                : 'avgCost',
        AggregationMethod   : 'average',
        AggregatableProperty: EstCost,
        @Common.Label       : 'Average Cost'
    }
);

annotate service.TrainingRequests with @UI.Chart #StatusChart: {
    Title              : 'Requests by Status',
    ChartType          : #Donut,
    DynamicMeasures    : ['@Analytics.AggregatedProperty#countRequests'],
    Dimensions         : [StatusName],
    MeasureAttributes  : [{
        DynamicMeasure: '@Analytics.AggregatedProperty#countRequests',
        Role          : #Axis1
    }],
    DimensionAttributes: [{
        Dimension: StatusName,
        Role     : #Category
    }]
};

annotate service.TrainingRequests with @UI.Chart #CostByTraining: {
    Title              : 'Estimated Cost by Training',
    ChartType          : #Bar,
    DynamicMeasures    : ['@Analytics.AggregatedProperty#totalCost'],
    Dimensions         : [TrainingName],
    MeasureAttributes  : [{
        DynamicMeasure: '@Analytics.AggregatedProperty#totalCost',
        Role          : #Axis1
    }],
    DimensionAttributes: [{
        Dimension: TrainingName,
        Role     : #Category
    }]
};

annotate service.TrainingRequests with @UI.Chart #RequestsByDate: {
    Title              : 'Requests by Date',
    ChartType          : #Line,
    DynamicMeasures    : ['@Analytics.AggregatedProperty#countRequests'],
    Dimensions         : [BeginDate],
    MeasureAttributes  : [{
        DynamicMeasure: '@Analytics.AggregatedProperty#countRequests',
        Role          : #Axis1
    }],
    DimensionAttributes: [{
        Dimension: BeginDate,
        Role     : #Category
    }]
};

annotate service.TrainingRequests with @UI.PresentationVariant #Main: {
    GroupBy       : [
        StatusName,
        TrainingName
    ],
    Total         : [
        RequestCount,
        EstCost
    ],
    Visualizations: [
        '@UI.Chart#StatusChart',
        '@UI.LineItem'
    ]
};

annotate service.TrainingRequests with @UI.LineItem: [
    {
        Value: TrainingRequestID,
        Label: 'Request ID'
    },
    {
        Value: TrainingName,
        Label: 'Training'
    },
    {
        Value: EmployeeID,
        Label: 'Employee'
    },
    {
        Value: DepartmentName,
        Label: 'Department'
    },
    {
        Value: Provider,
        Label: 'Provider'
    },
    {
        Value: BeginDate,
        Label: 'Start Date'
    },
    {
        Value: EndDate,
        Label: 'End Date'
    },
    {
        Value: EstCost,
        Label: 'Estimated Cost'
    },
    {
        Value: CurrencyCode,
        Label: 'Currency'
    },
    {
        Value: StatusName,
        Label: 'Status'
    }
];

annotate service.TrainingRequests with @UI.SelectionFields: [
    StatusName,
    TrainingName,
    DepartmentName,
    BeginDate,
    EndDate
];

annotate service.TrainingRequests {
    TrainingRequestUUID @UI.Hidden;
    RequestCount        @UI.Hidden;
    TrainingRequestID   @Common.Label: 'Request ID';
    BeginDate           @Common.Label: 'Start Date';
    EndDate             @Common.Label: 'End Date';
    Provider            @Common.Label: 'Provider';
    EstCost             @Common.Label: 'Estimated Cost';
    CurrencyCode        @Common.Label: 'Currency';
    StatusCode          @Common.Label: 'Status Code';
    StatusName          @Common.Label: 'Status';
    EmployeeID          @Common.Label: 'Employee';
    EmployeeFirstName   @Common.Label: 'First Name';
    EmployeeLastName    @Common.Label: 'Last Name';
    DepartmentID        @Common.Label: 'Department ID';
    DepartmentName      @Common.Label: 'Department';
    PositionID          @Common.Label: 'Position ID';
    PositionName        @Common.Label: 'Position';
    TrainingID          @Common.Label: 'Training ID';
    TrainingName        @Common.Label: 'Training';
    createdAt           @Common.Label: 'Created On';
};
