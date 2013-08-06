using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Mvc;
using BannerDataDictionary.Models;
using Dapper;

namespace BannerDataDictionary.Controllers
{
    [Authorize]
    public class HomeController : ApplicationController
    {
        public ActionResult Index()
        {
            ViewBag.Message = "Banner Tables";
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["MainDb"].ConnectionString))
            {
                conn.Open();
                IEnumerable<Table> resultList = conn.Query<Table>(@"EXEC usp_GetBannerTableNamesAndComments");
                return View(resultList);
            }
        }

        public ActionResult Details(string id)
        {
            ViewBag.Message = "Table Details";
            var viewModel = new TableDetailsModel { TableName = id };
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["MainDb"].ConnectionString))
            {
                conn.Open();
                IEnumerable<Table> tables = conn.Query<Table>(@"EXEC usp_GetBannerTableNamesAndComments @TableNames = '" + id + "'");
                IEnumerable<Column> columnsList = conn.Query<Column>(@"EXEC usp_GetBannerColumnNamesCommentsAndDataTypes @TableNames = '" + id + "'");

                // This returns a list of index columns for every index.
                IEnumerable<DapperIndex> dapperIndexColumns = conn.Query<DapperIndex>(@"EXEC usp_GetBannerIndexColumnNames @TableNames = '" + id + "'");

                // This returns a list of constraint columns for every constraint.
                IEnumerable<DapperConstraint> dapperConstraintColumns = conn.Query<DapperConstraint>(@"EXEC usp_GetBannerConstraintColumnNames @TableNames = '" + id + "'");

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
