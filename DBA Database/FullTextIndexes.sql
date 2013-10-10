CREATE FULLTEXT INDEX ON [dbo].[ServerOwnerTableColumn]
    ([TableName] LANGUAGE 1033, [Comments] LANGUAGE 1033, [ColumnName] LANGUAGE 1033, [ColumnComments] LANGUAGE 1033)
    KEY INDEX [ServerOwnerTableColumn_Id_UDX]
    ON [DBA_FullTextCatalog];

