CREATE TABLE [dbo].[DataDictionary] (
    [sqlinstance]     VARCHAR (128)  NOT NULL,
    [databasename]    VARCHAR (128)  NOT NULL,
    [tableschema]     VARCHAR (128)  NULL,
    [tablename]       VARCHAR (128)  NULL,
    [columnname]      VARCHAR (128)  NULL,
    [BusinessPurpose] VARCHAR (128)  NULL,
    [xtype]           VARCHAR (8)    NULL,
    [DataType]        VARCHAR (128)  NULL,
    [description]     NVARCHAR (MAX) NULL
);


GO
CREATE CLUSTERED INDEX [DBA_DataDictionary_sqlinstancedatabasenametableschematablenamecolumnname_CLIDX]
    ON [dbo].[DataDictionary]([sqlinstance] ASC, [databasename] ASC, [tableschema] ASC, [tablename] ASC, [columnname] ASC);

