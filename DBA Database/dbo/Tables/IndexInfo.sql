CREATE TABLE [dbo].[IndexInfo] (
    [LinkedServerName] VARCHAR (100) NOT NULL,
    [IndexName]        VARCHAR (200) NOT NULL,
    [Owner]            VARCHAR (200) NOT NULL,
    [TableName]        VARCHAR (200) NOT NULL,
    [ColumnName]       VARCHAR (200) NOT NULL,
    [ColumnPosition]   INT           NULL,
    [SortOrder]        VARCHAR (5)   NULL,
    [Uniqueness]       VARCHAR (50)  NULL,
    [DistinctKeys]     INT           NULL,
    CONSTRAINT [PK_IndexInfo] PRIMARY KEY CLUSTERED ([LinkedServerName] ASC, [IndexName] ASC, [Owner] ASC, [TableName] ASC, [ColumnName] ASC)
);

