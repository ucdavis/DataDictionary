﻿using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using BannerDataDictionary.Models;
using Dapper;

namespace BannerDataDictionary.Controllers
{
    public class TablesController : ApplicationController
    {
        //public ActionResult Index()
        //{
        //    ViewBag.Message = "Banner Tables";
        //    using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["MainDb"].ConnectionString))
        //    {
        //        conn.Open();
        //        IEnumerable<Table> resultList = conn.Query<Table>(@"EXEC usp_GetBannerTableNamesAndComments");
        //        return View(resultList);
        //    }
        //}

        // id = LinkedServer
        public ActionResult Index(DatabaseOwner oid)
        {
            if (oid == null)
            {
                ViewBag.Message = "Error: Must provide a Linked Server and Database Owner";
                return RedirectToAction("Index", "Home", new {Message = "Must Select a Linked Server to continue!"});
            }
            else
            {
                var id = new LinkedServer();
                var includeEmptyTables = oid.IncludeEmptyTables ?? false;
                var linkedServerName = oid.LinkedServerName as string ?? "SIS";
                //var databaseOwners = oid.Owner //as List<DatabaseOwner>;
                var databaseOwnerName = oid.Owner ?? "SATURN";

                //if (databaseOwners == null || !databaseOwners.Any())
                //{
                //    databaseOwners = new List<DatabaseOwner>
                //        {
                //            new DatabaseOwner {LinkedServerName = linkedServerName, Owner = databaseOwnerName}
                //        };
                //}
                //else
                //{
                //    databaseOwners = id.DatabaseOwners as List<DatabaseOwner>;
                //    var first = databaseOwners.FirstOrDefault();
                //    if (first != null) databaseOwnerName = first.Owner;
                //}

                var message = " Tables";
                //if (databaseOwners.First().Owner.Equals("SATURN"))
                if (databaseOwnerName.Equals("SATURN"))
                {
                    message = "Banner" + message;
                }
                else
                {
                    message = linkedServerName +'.' + databaseOwnerName + message;
                }
                ViewBag.Message = message;

                using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["MainDb"].ConnectionString))
                {
                    conn.Open();
                    var loginId = User.Identity.Name;
                    var bannerUserList = conn.Query(string.Format("SELECT LoginId FROM BannerLoginIds WHERE LoginId = '{0}'", loginId)).ToList();
                    var includeBannerItems = bannerUserList.Count() == 1 ? true : false;

                    IList<Table> tables =
                        conn.Query<Table>(@"EXEC usp_GetLinkedServerTableNamesAndComments 
                            @Owners = @databaseOwnerName, 
                            @LinkedServerNames = @linkedServerName, 
                            @IncludeEmptyTables = @includeEmptyTables, 
                            @IncludeBannerItems = @includeBannerItems",
                            new { @databaseOwnerName = databaseOwnerName, @linkedServerName = linkedServerName, @includeEmptyTables = includeEmptyTables, @IncludeBannerItems = includeBannerItems}).ToList();

                    if (tables.Count == 1)
                    {
                        // means we got back a single matching table => jump to table details page:
                        var table = tables.FirstOrDefault();
                        
                        return RedirectToAction("Details", "Tables", new { table.LinkedServerName, table.Owner, table.TableName, IncludeEmptyTables=includeEmptyTables});
                    }

                    return View(tables);
                }
            }
        }

        // id = table name
        public ActionResult Details(Table id)
        {
            var isTable = true;

            var linkedServerName = id.LinkedServerName ?? "SIS";
            var databaseOwner = id.Owner ?? "SATURN";
            var tableName = id.TableName;

            var viewModel = new TableDetailsModel { 
                LinkedServerName = linkedServerName,
                Owner = databaseOwner,
                TableName = tableName
            };
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["MainDb"].ConnectionString))
            {
                conn.Open();

                var loginId = User.Identity.Name;
                var bannerUserList = conn.Query(string.Format("SELECT LoginId FROM BannerLoginIds WHERE LoginId = '{0}'", loginId)).ToList();
                var includeBannerItems = bannerUserList.Count() == 1 ? true : false;

                IList<Table> tables = conn.Query<Table>(@"EXEC usp_GetLinkedServerTableNamesAndComments @TableNames = @tableName, @LinkedServerNames = @linkedServerName, @Owners = @databaseOwner, @IncludeBannerItems = @includeBannerItems", new { @tableName = tableName, @linkedServerName = linkedServerName, @databaseOwner = databaseOwner, @includeBannerItems = includeBannerItems }).ToList();
                IList<Column> columnsList = conn.Query<Column>(@"EXEC usp_GetLinkedServerColumnNamesCommentsAndDataTypes @TableNames = @tableName, @LinkedServerNames = @linkedServerName, @Owners = @databaseOwner, @IncludeBannerItems = @includeBannerItems", new { @tableName = tableName, @linkedServerName = linkedServerName, @databaseOwner = databaseOwner, @includeBannerItems = includeBannerItems }).ToList();

                // This returns a list of index columns for every index.
                IList<DapperIndex> dapperIndexColumns = conn.Query<DapperIndex>(@"EXEC usp_GetLinkedServerIndexColumnNames @TableNames = @tableName, @LinkedServerNames = @linkedServerName, @Owners = @databaseOwner, @IncludeBannerItems = @includeBannerItems", new { @tableName = tableName, @linkedServerName = linkedServerName, @databaseOwner = databaseOwner, @includeBannerItems = includeBannerItems }).ToList();

                // This returns a list of constraint columns for every constraint.
                IList<DapperConstraint> dapperConstraintColumns = conn.Query<DapperConstraint>(@"EXEC usp_GetLinkedServerConstraintColumnNames @TableNames = @tableName, @LinkedServerNames = @linkedServerName, @Owners = @databaseOwner, @IncludeBannerItems = @includeBannerItems", new { @tableName = tableName, @linkedServerName = linkedServerName, @databaseOwner = databaseOwner, @includeBannerItems = includeBannerItems }).ToList();

                var firstOrDefault = tables.FirstOrDefault();
                if (firstOrDefault != null)
                {
                    viewModel.Owner = firstOrDefault.Owner;
                    viewModel.TableComments = firstOrDefault.Comments ?? String.Empty;
                    viewModel.Text = firstOrDefault.Text ?? String.Empty;
                    viewModel.NumRows = firstOrDefault.NumRows;
                    viewModel.TableType = firstOrDefault.TableType;
                    if (!firstOrDefault.TableType.Equals("TABLE")) 
                        isTable = false;
                }
                viewModel.Columns = columnsList.ToList();
                
                //Indexes:
                viewModel.Indexes = new List<DapperIndex>();
                var distinctIndexes =
                    dapperIndexColumns.GroupBy(idx => idx.IndexName,(key, group) => group.First()).Select(
                    col => new DapperIndex
                        {
                            IndexName = col.IndexName,
                            Owner = col.Owner,
                            TableName = col.TableName,
                            Uniqueness = col.Uniqueness,
                            ColumnName = string.Empty ,
                            ColumnPosition = string.Empty,
                            DistinctKeys = col.DistinctKeys,
                            SortOrder = string.Empty
                        }).ToList();

                foreach (var distinctIndex in distinctIndexes)
                {
                    viewModel.Indexes.Add(distinctIndex);

                    var indexColumns = dapperIndexColumns.Where(x => (x.IndexName == distinctIndex.IndexName)).ToList();
                    foreach (var indexColumn in indexColumns)
                    {
                        viewModel.Indexes.Add(new DapperIndex
                            {
                                IndexName = string.Empty,
                                Owner = indexColumn.Owner,
                                TableName = indexColumn.TableName,
                                Uniqueness = string.Empty,
                                ColumnName = indexColumn.ColumnName,
                                ColumnPosition = indexColumn.ColumnPosition,
                                DistinctKeys = string.Empty,
                                SortOrder = indexColumn.SortOrder
                            });
                    }
                }

                // Constraints:
                viewModel.Constraints = new List<DapperConstraint>();
                var distinctConstraints =
                    dapperConstraintColumns.GroupBy(cnstrnt => cnstrnt.ConstraintName, (key, group) => group.First()).Select(
                    col => new DapperConstraint()
                    {
                        ConstraintName = col.ConstraintName,
                        Owner = col.Owner,
                        TableName = col.TableName,
                        ColumnName = string.Empty,
                        ColumnPosition = string.Empty,
                        ConstraintType = col.ConstraintType,
                        Status =col.Status
                    }).ToList();

                foreach (var constraint in distinctConstraints)
                {
                    viewModel.Constraints.Add(constraint);

                    var constraintColumns =
                        dapperConstraintColumns.Where(x => (x.ConstraintName == constraint.ConstraintName)).ToList();
                    foreach (var constraintColumn in constraintColumns)
                    {
                        viewModel.Constraints.Add(new DapperConstraint()
                            {
                                ConstraintName = string.Empty,
                                Owner = constraintColumn.Owner,
                                TableName = constraintColumn.TableName,
                                ColumnName = constraintColumn.ColumnName,
                                ColumnPosition = constraintColumn.ColumnPosition,
                                ConstraintType = string.Empty,
                                Status = string.Empty
                            });
                    }
                }

                ViewBag.Message = (isTable ? "Table" : "View") + " Details";

                return View(viewModel);
            }
        }

        public ActionResult ColumnLocations(string id)
        {
            return View();
        }

    }
}
