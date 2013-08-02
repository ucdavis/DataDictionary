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

                IEnumerable<DapperIndex> dapperIndexes = conn.Query<DapperIndex>(@"EXEC usp_GetBannerIndexColumnNamesForTable @TableName = '" + id + "'");



                var firstOrDefault = tables.FirstOrDefault();
                if (firstOrDefault != null)
                {
                    viewModel.Owner = firstOrDefault.Owner;
                    viewModel.TableComments = firstOrDefault.Comments ?? String.Empty;
                    viewModel.NumRows = firstOrDefault.NumRows;
                    
                }
                viewModel.Columns = columnsList.ToList();
                
                viewModel.Indexes = new List<DapperIndex>();
                var dapperIndices = dapperIndexes as IList<DapperIndex> ?? dapperIndexes.ToList();
                var result =
                    dapperIndices.Select(
                        idx =>
                        new DapperIndex
                            {
                                IndexName = idx.IndexName,
                                Owner = idx.Owner,
                                TableName = idx.TableName,
                                Uniqueness = idx.Uniqueness,
                                ColumnName = idx.ColumnName,
                                ColumnPosition = idx.ColumnPosition,
                                DistinctKeys = idx.DistinctKeys,
                                SortOrder = idx.SortOrder
                            });

                foreach (var namedIndex in result)
                {
                    viewModel.Indexes.Add(namedIndex);

                    var columns = dapperIndexes.Select(col => new DapperIndex
                        {
                            IndexName = string.Empty,
                            Owner = col.Owner,
                            Uniqueness = string.Empty,
                            ColumnName = col.ColumnName,
                            ColumnPosition = col.ColumnPosition,
                            DistinctKeys = string.Empty,
                            SortOrder = col.SortOrder
                        })
                                               .Where(
                                                   x =>
                                                   x.IndexName == namedIndex.IndexName && x.Owner == namedIndex.Owner &&
                                                   x.TableName == namedIndex.TableName)
                                               .OrderBy(y => y.ColumnPosition);


                    foreach (var dapperIndex in columns)
                    {
                        viewModel.Indexes.Add(dapperIndex);
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
