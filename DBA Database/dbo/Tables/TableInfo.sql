CREATE TABLE [dbo].[TableInfo] (
    [LinkedServerName] VARCHAR (100)   NOT NULL,
    [Owner]            NVARCHAR (200)  NOT NULL,
    [TableName]        NVARCHAR (200)  NOT NULL,
    [Comments]         NVARCHAR (4000) NULL,
    [Text]             NTEXT           NULL,
    [NumRows]          INT             NULL,
    [TableType]        NVARCHAR (20)   NULL,
    CONSTRAINT [PK_TableInfo] PRIMARY KEY CLUSTERED ([LinkedServerName] ASC, [Owner] ASC, [TableName] ASC)
);


GO
CREATE NONCLUSTERED INDEX [TableInfo_NumRows_CVIDX]
    ON [dbo].[TableInfo]([NumRows] ASC)
    INCLUDE([LinkedServerName], [Owner], [TableName]);

