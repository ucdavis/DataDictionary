using System;
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

        // id = DatabaseOwner
        public ActionResult Index(DatabaseOwner id)
        {
            if (id == null)
            {
                ViewBag.Message = "Error: Must provide a Linked Server and Database Owner";
                return RedirectToAction("Index", "Home", new { Message = "Must Select a Linked Server to continue!" });
            }
            else
            {
                var includeEmptyTables = id.IncludeEmptyTables ?? false; 
                var linkedServerName = id.LinkedServer as string ?? "SIS";
                var databaseOwnerName = id.Owner as string ?? "SATURN";

                var message = " Tables";
                if (String.IsNullOrEmpty(databaseOwnerName))
                {
                    message = "Banner" + message;
                }
                else
                {
                    message = databaseOwnerName + message;
                }
                ViewBag.Message = message;

                using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["MainDb"].ConnectionString))
                {
                    conn.Open();
                    IList<Table> tables =
                        conn.Query<Table>(@"EXEC usp_GetOracleTableNamesAndComments @Owners = '" + databaseOwnerName +
                                          "', @LinkedServerName = '" + linkedServerName + "', @IncludeEmptyTables = " + includeEmptyTables).ToList();
                    return View(tables);
                }
            }
        }

        // id = table name
        public ActionResult Details(Table id)
        {
            ViewBag.Message = "Table Details";
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
                IList<Table> tables = conn.Query<Table>(@"EXEC usp_GetOracleTableNamesAndComments @TableNames = '" + tableName + "', @LinkedServerName = '" + linkedServerName + "', @Owners = '" + databaseOwner + "'").ToList();
                IList<Column> columnsList = conn.Query<Column>(@"EXEC usp_GetOracleColumnNamesCommentsAndDataTypes @TableNames = '" + tableName + "', @LinkedServerName = '" + linkedServerName + "', @Owners = '" + databaseOwner + "'").ToList();

                // This returns a list of index columns for every index.
                IList<DapperIndex> dapperIndexColumns = conn.Query<DapperIndex>(@"EXEC usp_GetOracleIndexColumnNames @TableNames = '" + tableName + "', @LinkedServerName = '" + linkedServerName + "', @Owners = '" + databaseOwner + "'").ToList();

                // This returns a list of constraint columns for every constraint.
                IList<DapperConstraint> dapperConstraintColumns = conn.Query<DapperConstraint>(@"EXEC usp_GetBannerConstraintColumnNames @TableNames = '" + tableName + "', @LinkedServerName = '" + linkedServerName + "', @Owners = '" + databaseOwner + "'").ToList();

                var firstOrDefault = tables.FirstOrDefault();
                if (firstOrDefault != null)
                {
                    viewModel.Owner = firstOrDefault.Owner;
                    viewModel.TableComments = firstOrDefault.Comments ?? String.Empty;
                    viewModel.NumRows = firstOrDefault.NumRows;
                    
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

                return View(viewModel);
            }
        }

        public ActionResult ColumnLocations(string id)
        {
            return View();
        }

    }
}
