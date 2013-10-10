CREATE TABLE [dbo].[ServerOwnerTableColumn] (
    [Id]               INT             IDENTITY (100, 1) NOT NULL,
    [LinkedServerName] VARCHAR (100)   NOT NULL,
    [Owner]            VARCHAR (200)   NOT NULL,
    [TableName]        VARCHAR (200)   NOT NULL,
    [Comments]         NVARCHAR (4000) NULL,
    [ColumnName]       VARCHAR (200)   NOT NULL,
    [ColumnComments]   NVARCHAR (4000) NULL,
    [NumRows]          INT             NULL,
    [TableType]        NVARCHAR (20)   NULL,
    CONSTRAINT [PK_ServerOwnerTableColumn] PRIMARY KEY CLUSTERED ([LinkedServerName] ASC, [Owner] ASC, [TableName] ASC, [ColumnName] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ServerOwnerTableColumn_Id_UDX]
    ON [dbo].[ServerOwnerTableColumn]([Id] ASC);

