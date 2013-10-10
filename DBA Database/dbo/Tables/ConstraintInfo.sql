CREATE TABLE [dbo].[ConstraintInfo] (
    [LinkedServerName] VARCHAR (100) NOT NULL,
    [ConstraintName]   VARCHAR (200) NOT NULL,
    [Owner]            VARCHAR (200) NOT NULL,
    [TableName]        VARCHAR (200) NOT NULL,
    [ColumnName]       VARCHAR (200) NOT NULL,
    [ColumnPosition]   INT           NULL,
    [Status]           VARCHAR (25)  NULL,
    [ConstraintType]   VARCHAR (5)   NOT NULL,
    CONSTRAINT [PK_ConstraintInfo] PRIMARY KEY CLUSTERED ([LinkedServerName] ASC, [ConstraintName] ASC, [Owner] ASC, [TableName] ASC, [ColumnName] ASC)
);

