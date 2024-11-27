-- Use the following to create the Tulip Common Data Structure in a new data base "Tulip" in Snowflake.

CREATE OR replace database TULIP;

CREATE or replace SCHEMA TULIP.COMMON_DATA_MODEL;

CREATE OR REPLACE TABLE Equipment_and_Assets (
    ID TEXT NOT NULL COMMENT 'Required unique identifier'
    , Name TEXT 
        COMMENT 'The name of the asset, device, or equipment'
    , Description TEXT 
        COMMENT 'A short description of the asset, device, or equipment'
    , Status TEXT 
        COMMENT 'The status or current condition of the asset, device, or equipment.'
    , Location TEXT 
        COMMENT 'The current physical location of the asset, device, or equipment.'
    , Type TEXT 
        COMMENT 'The type of asset, device, or equipment'
    , Last_Calibration TIMESTAMP 
        COMMENT 'The last date that a periodic review for acceptance was completed'
    , Calibration_Cadence NUMBER 
        COMMENT 'The duration between scheduled maintenance activity or periodic review for acceptance.'
    )
    COMMENT = 'Reusable equipment or devices, not part of the Bill of Materials, but may be required for procedures and may require calibration.'; 


CREATE OR REPLACE TABLE Inventory_Items (
    ID TEXT NOT NULL COMMENT 'Required unique identifier',
    Material_Definition_ID TEXT COMMENT 'Unique identifier for the material',
    Material_Definition_Type TEXT COMMENT 'Type of material of the inventory item',
    Status TEXT COMMENT 'The current state of the inventory item',
    Location_ID TEXT COMMENT 'Current physical location of the inventory',
    Location_Area TEXT COMMENT 'Further subdivision of locations by area, which allows for grouping or filtering by area or zone',
    Quantity NUMBER COMMENT 'The quantity of the inventory record',
    Unit_of_Measure TEXT COMMENT 'The unit of measure related to the quantity'
) COMMENT = 'Holds inventory by location and item.';

CREATE OR REPLACE TABLE Locations (
    ID TEXT NOT NULL COMMENT 'Required unique identifier',
    Location_Area TEXT COMMENT 'A grouping of locations or the next level of location hierarchy',
    BIN_Number INTEGER COMMENT 'A value associated with the current location',
    Light_Kit_Number INTEGER COMMENT 'A value associated with the Tulip light kit',
    Type TEXT COMMENT 'A categorization of locations for filtering or sorting by type',
    Status TEXT COMMENT 'The current status or condition of the location'
) COMMENT = 'Physical locations on the production floor. They can be associated with light kit locations for pick-to-light.';

CREATE OR REPLACE TABLE Stations (
    ID TEXT NOT NULL COMMENT 'Required unique identifier',
    Status TEXT COMMENT 'The current station status (e.g. Running, Down, Idle, Paused)',
    Status_Color VARCHAR COMMENT 'Color of the current station status',
    Status_Detail TEXT COMMENT 'Information about the station (e.g. reason downtime)',
    Process_Cell TEXT COMMENT 'The process cell that is part of the station',
    Operator TEXT COMMENT 'The operator currently working at the station',
    Work_Order_ID TEXT COMMENT 'Unique identifier for the work order currently in progress at the station',
    Material_Definition_ID TEXT COMMENT 'Unique identifier for the material used in the work order in progress'
);

CREATE OR REPLACE TABLE Units (
    ID TEXT NOT NULL COMMENT 'Required unique identifier'
    , Material_Definition_ID TEXT 
        COMMENT 'Unique identifier of the material of the unit'
    , Material_Definition_Type TEXT 
        COMMENT 'The type of material of the unit'
    , Status TEXT 
        COMMENT 'The current state of the unit (e.g., In Progress, Available, Unavailable)'
    , Location TEXT 
        COMMENT 'The physical location on the shopfloor or in inventory (e.g. station ID, location ID)'
    , Quantity NUMBER 
        COMMENT 'Quantity of the Unit'
    , Unit_of_Measure TEXT 
        COMMENT 'The standard unit used to quantify the unit (e.g., kg, mg, liters)'
    , Work_Order_ID TEXT 
        COMMENT 'Unique identifier of the work order'
    , Completed_Date TIMESTAMP 
        COMMENT 'The time the unit was completed'
    , Produced_by TEXT 
        COMMENT 'The operator who completed the unit'
    , Parent_Unit_ID TEXT 
        COMMENT 'Unique identifier of the parent unit'
    )
    COMMENT = 'Used to store unique physical lots, serial numbers, and batches.';


CREATE OR REPLACE TABLE Actions (
    ID TEXT NOT NULL COMMENT 'Required unique identifier'
    , Material_Definition_ID TEXT 
        COMMENT 'Unique identifier of the material definition'
    , Title TEXT 
        COMMENT 'Short description to identify the nature of the action'
    , Location TEXT 
        COMMENT 'Physical place the action is in reference to or is acted upon'
    , Severity TEXT 
        COMMENT 'Impact of the defect on the process (e.g. Critical, High, Medium, Low)'
    , Status TEXT 
        COMMENT 'Current status of the action (e.g. Now, In progress, Closed)'
    , Work_Order_ID TEXT 
        COMMENT 'Unique identifier of the work order the action is related to'
    , Unit_ID TEXT 
        COMMENT 'Unique identifier of the related unit'
    , Comments TEXT 
        COMMENT 'Further description or notes related to the action'
    , Photo VARIANT 
        COMMENT 'Related image'
    , Reported_By TEXT 
        COMMENT 'The user who created the issue'
    , Owner TEXT 
        COMMENT 'The user responsible for carrying out the action'
    , Type TEXT 
        COMMENT 'Category of actions for filtering or analysis'
    , Actions_Taken TEXT 
        COMMENT 'If closed, description of actions taken'
    , Due_Date TIMESTAMP 
        COMMENT 'Date the action must be completed'
    )
    COMMENT = 'Holds events that require follow up.';

CREATE OR REPLACE TABLE Defects (
    ID TEXT NOT NULL COMMENT 'Required unique identifier',
    "Material Definition ID" TEXT COMMENT 'Unique identifier of the material definition',
    Reason TEXT COMMENT 'Support routing to correct owner, swift resolution, and root cause analysis',
    Location TEXT COMMENT 'The physical place where the defect was detected',
    Severity TEXT COMMENT 'Impact of the defect on the process',
    Status TEXT COMMENT 'Current status of the defect',
    "Work Order ID" TEXT COMMENT 'Unique identifier of the Work Order the defect is related to',
    "Unit ID" TEXT COMMENT 'Unique identifier of the related material unit',
    Comments TEXT COMMENT 'Further description or notes related to the defect',
    Photo VARIANT COMMENT 'Image of the defect',
    Quantity NUMBER COMMENT 'Quantity of the defective materials',
    "Reported By" TEXT COMMENT 'User who logs the defect/event',
    Disposition TEXT COMMENT 'Action taken to resolve the defect',
    "Disposition Assignee" TEXT COMMENT 'User who has been assigned the action or lead the next steps with the defect investigation',
    "Dispositioned Date" TIMESTAMP COMMENT 'Date that the disposition starts',
    Closed TIMESTAMP COMMENT 'Date that the defect was resolved and closed',
    "Material ID" TEXT COMMENT 'Unique identifier of the defective material'
);

CREATE OR REPLACE TABLE Inspection_Results (
    ID TEXT NOT NULL COMMENT 'Required unique identifier',
    "Work Order ID" TEXT COMMENT 'Unique identifier for the work order',
    "Unit ID" TEXT COMMENT 'Unique identifier for the physical unit',
    "Material Definition ID" TEXT COMMENT 'Unique identifier of the material definition',
    Type TEXT COMMENT 'Further categorization or classification of the type of result',
    Status TEXT COMMENT 'Current status of the inspection demand',
    Procedure TEXT COMMENT 'Procedure ID for inspection',
    Location TEXT COMMENT 'Location where the inspection was executed',
    Photo VARIANT COMMENT 'Image of the result',
    Passed BOOLEAN COMMENT 'True/false value for whether the inspection passed',
    Operator TEXT COMMENT 'Operator who executed the inspection',
    "Text Value" TEXT COMMENT 'Text value captured',
    Measured NUMBER COMMENT 'Measured actual value',
    Target NUMBER COMMENT 'Measured target value',
    LSL NUMBER COMMENT 'The lower specification limit when the measurement was performed',
    USL NUMBER COMMENT 'The upper specification limit when the measurement was performed'
);

CREATE OR REPLACE TABLE Kanban_Cards (
    ID TEXT NOT NULL COMMENT 'Required unique identifier',
    "Part Number" TEXT COMMENT 'Unique identifier of the part',
    Status TEXT COMMENT 'Current status',
    "Consuming Location" TEXT COMMENT 'The physical location of the consumed part',
    Supplier TEXT COMMENT 'Name of the part supplier',
    Quantity NUMBER COMMENT 'Quantity of required parts',
    "Lead Time" NUMBER COMMENT 'The time expected from empty to replenish',
    "Part Description" TEXT COMMENT 'Physical description of the part required',
    "Status Color" TEXT COMMENT 'Color to indicate status of the request',
    Image VARIANT COMMENT 'Photo of the part',
    Active BOOLEAN COMMENT 'True/false value for whether the kanban is active'
);

CREATE OR REPLACE TABLE Material_Requests (
    ID TEXT NOT NULL COMMENT 'Required unique identifier',
    "Material Definition ID" TEXT COMMENT 'Unique identifier of the material definition',
    "Requesting Location" TEXT COMMENT 'Physical location that requested the replenishment',
    "Supplier Location" TEXT COMMENT 'Physical location that will replenish the material',
    "Kanban Card ID" TEXT COMMENT 'Unique identifier of the kanban card definition',
    Quantity NUMBER COMMENT 'Quantity of materials to be replenished',
    Status TEXT COMMENT 'Current status of the request',
    "Status Color" TEXT COMMENT 'Color to indicate status of the request',
    Requester TEXT COMMENT 'User who initiated the material request',
    Assignee TEXT COMMENT 'User who received the material request',
    Requested TIMESTAMP COMMENT 'Date the material was requested',
    Started TIMESTAMP COMMENT 'Date the material request started',
    Completed TIMESTAMP COMMENT 'Date the material request was fulfilled',
    Bin TEXT COMMENT 'Bin requesting location where the material should be delivered',
    "Completed By" TEXT COMMENT 'User who provided the material to fulfill the replenishment request',
    "Ready for pick time" TIMESTAMP COMMENT 'Date that the material is ready to be picked',
    "Delivered by" TEXT COMMENT 'User who delivered the material to the requesting location'
);

CREATE OR REPLACE TABLE Work_Orders (
    ID TEXT NOT NULL COMMENT 'Required unique identifier',
    Operator TEXT COMMENT 'User who completed the work order',
    "Parent Order ID" TEXT COMMENT 'Unique identifier of the parent work order',
    "Material Definition ID" TEXT COMMENT 'Unique identifier of the material definition',
    Status TEXT COMMENT 'Current status of the work order',
    Location TEXT COMMENT 'Physical place where the work order exists',
    "Quantity Required" NUMBER COMMENT 'Quantity of parts that need to be produced',
    "Quantity Complete" NUMBER COMMENT 'Actual quantity produced',
    "Quantity Scrap" NUMBER COMMENT 'Quantity of units that were scrapped associated with the work order',
    "Due Date" TIMESTAMP COMMENT 'Date that the work order is due',
    "Start Date" TIMESTAMP COMMENT 'Date that the work order was started',
    "Complete Date" TIMESTAMP COMMENT 'Date that the work order was completed',
    "Customer ID" TEXT COMMENT 'Unique identifier of the company or entity the work order is being fulfilled to'
);

-- Log Tables
-- Logs are a secondary table type within the Tulip Common Data Model, as they do not fit within a Digital Twin model and should only be considered by advanced users. You should only include Log tables once you've gone through the Solution Design process and exhausted all other options. Log tables should NEVER serve as the foundation for an app solution.
CREATE OR REPLACE TABLE Genealogy_Records (
    ID TEXT NOT NULL COMMENT 'Required unique identifier',
    Parent_Unit_ID TEXT COMMENT 'Unique identifier of the parent unit (e.g. serial number)',
    Parent_Material_Definition_ID TEXT COMMENT 'Unique identifier of the part number for parent assembly',
    Parent_Description TEXT COMMENT 'Description of the parent assembly',
    Component_Unit_ID TEXT COMMENT 'Unique identifier of a component in the parent assembly (e.g. Material Lot Number)',
    Component_Material_Definition_ID TEXT COMMENT 'Unique identifier of the component',
    Component_Description TEXT COMMENT 'Description of the component',
    Component_Quantity NUMBER COMMENT 'Quantity of the components',
    Component_UoM TEXT COMMENT 'Unit of measurement of the component',
    Work_Order_ID TEXT COMMENT 'Unique identifier of the related work order'
)
COMMENT = 'Each record is a parent/child relationship. The child could be either a serialized or unserialized subassembly or individual part.';

CREATE OR REPLACE TABLE Notes_and_Comments (
    ID TEXT NOT NULL COMMENT 'Required unique identifier',
    Reference_ID TEXT COMMENT 'Unique identifier of the work order, shift, or other process artifact for reference',
    Location TEXT COMMENT 'Location where the note was taken (station ID, location ID, any arbitrary indication of a location such as area, cell, unit)',
    Notes TEXT COMMENT 'Field tracking the user\'s note or comment',
    Sender TEXT COMMENT 'User who sent the note',
    Updated_By TEXT COMMENT 'User who wrote the comment',
    Recipient TEXT COMMENT 'User who received the notes',
    Notes_Photo VARIANT COMMENT 'Photo of the notes'
);

CREATE OR REPLACE TABLE Station_Activity_History (
    ID TEXT NOT NULL COMMENT 'Required unique identifier',
    Station_ID TEXT COMMENT 'Unique identifier of the station related to the record',
    LOCATION TEXT COMMENT 'Physical Location of the station',
    Status TEXT COMMENT 'Current status of the station (e.g. Running, Down, Idle)',
    Start_Date_Time TIMESTAMP COMMENT 'Date and time that the station activity log started',
    End_Date_Time TIMESTAMP COMMENT 'Date and time that the station activity log ended',
    Duration NUMBER COMMENT 'Duration of the record',
    Material_Definition_ID TEXT COMMENT 'Unique identifier of the material produced during station activity',
    Target_Quantity NUMBER COMMENT 'Quantity of the material expected to be produced for the duration',
    Actual_Quantity NUMBER COMMENT 'Quantity of the material actually produced for the duration',
    Defects NUMBER COMMENT 'Quantity of the defective material captured for the duration',
    Downtime_Reason TEXT COMMENT 'Downtime collected during the station activity',
    Comments TEXT COMMENT 'Field tracking the user\'s notes or comments',
    Work_Order_ID TEXT COMMENT 'Unique identifier of the work order associated',
    Unit_ID TEXT COMMENT 'Unique identifier of the unit associated'
)
COMMENT = 'Stores a historical record of production output and status by station, grouped by hour. Similar in function and purpose to the machine activity table.';

-- REFERENCES
-- References are a secondary table type within the Tulip Common Data Model, as they do not fit within a Digital Twin model and should only be considered by advanced users. You should only include Reference tables once you've gone through the Solution Design process and exhausted all other options. Reference tables should NEVER serve as the foundation for an app solution.

CREATE OR REPLACE TABLE Bill_of_Materials (
    ID TEXT NOT NULL COMMENT 'Required unique identifier'
    , Parent_Material_Definition_ID TEXT COMMENT 'Unique identifier of the material definition of the parent assembly'
    , Parent_Material_Description TEXT COMMENT 'Description of the parent material'
    , Component_Material_Definition_ID TEXT COMMENT 'Unique identifier of the material definition of the component to be assembled or consumed'
    , Component_Material_Description TEXT COMMENT 'Description of the material to be assembled or consumed'
    , Component_Quantity NUMBER COMMENT 'Quantity of the material to assemble or consume'
    , Component_UoM TEXT COMMENT 'Unit of measure of the component'
    , Point_of_Use TEXT COMMENT 'Location, operation, or step where the material will be assembled or consumed'
    )
    COMMENT = 'This table is typically used in lieu of integration with a system of record that could pass this data in real time. This table holds a bill of material and procedures for a given product or parent item. It can be used to display required component items and quantities broken down by process step.';

CREATE OR REPLACE TABLE Materials_Definitions (
    ID TEXT NOT NULL COMMENT 'Required unique identifier'
    , Name TEXT COMMENT 'Name of the material definition'
    , Type TEXT COMMENT 'Categorization of materials (e.g., Raw vs Intermediate, Final vs Make, vs Buy)'
    , Description TEXT COMMENT 'Description of the material'
    , Image VARIANT COMMENT 'Image of the material'
    , Status TEXT COMMENT 'Current status of the material (e.g., New, Ready, Blocked, Obsolete)'
    , Unit_of_Measure TEXT COMMENT 'Unit of measure of the material'
    , Version_Revision TEXT COMMENT 'The number or letter representing the version/revision of the part'
    , Vendor_ID TEXT COMMENT 'Unique identifier of the supplier of the material'
    , Target_Cycle_Time NUMBER COMMENT 'Target amount of time to complete one unit'
    )
    COMMENT = 'Definitions of all items made, purchased, or assembled. This describes items and their specific properties.';
