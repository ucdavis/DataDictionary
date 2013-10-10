CREATE TABLE [dbo].[OwnerInfo] (
    [LinkedServerName] VARCHAR (100) NOT NULL,
    [Owner]            VARCHAR (200) NOT NULL,
    [NumTables]        INT           NULL,
    [NumTablesAll]     INT           NULL,
    CONSTRAINT [PK_OwnerInfo] PRIMARY KEY CLUSTERED ([LinkedServerName] ASC, [Owner] ASC)
);

