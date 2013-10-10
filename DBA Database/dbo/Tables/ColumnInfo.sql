CREATE TABLE [dbo].[ColumnInfo] (
    [LinkedServerName] VARCHAR (100)   NOT NULL,
    [Owner]            VARCHAR (200)   NOT NULL,
    [TableName]        VARCHAR (200)   NOT NULL,
    [ColumnName]       VARCHAR (200)   NOT NULL,
    [ColumnComments]   NVARCHAR (4000) NULL,
    [DataType]         NVARCHAR (200)  NULL,
    [DataLength]       NVARCHAR (50)   NULL,
    [DataPrecision]    NVARCHAR (50)   NULL,
    [DataScale]        NVARCHAR (50)   NULL,
    [Nullable]         NVARCHAR (1)    NULL,
    [ColumnID]         INT             NULL,
    CONSTRAINT [PK_ColumnInfo] PRIMARY KEY CLUSTERED ([LinkedServerName] ASC, [Owner] ASC, [TableName] ASC, [ColumnName] ASC)
);

