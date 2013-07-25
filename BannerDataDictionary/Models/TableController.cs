using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using BannerDataDictionary.Controllers;
using Dapper;

namespace BannerDataDictionary.Models
{
    public class TablesController : ApplicationController
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
                IEnumerable<Columns> columnsList = conn.Query<Columns>(@"EXEC usp_GetBannerColumnNamesCommentsAndDataTypes @TableNames = '" + id + "'");

                var firstOrDefault = tables.FirstOrDefault();
                if (firstOrDefault != null)
                {
                    viewModel.Owner = firstOrDefault.Owner;
                    viewModel.TableComments = firstOrDefault.Comments ?? String.Empty;
                    viewModel.NumRows = firstOrDefault.NumRows;
                }
                viewModel.Columns = columnsList.ToList();

                return View(viewModel);
            }
        }

        public ActionResult ColumnLocations(string id)
        {
            return View();
        }

       

    }
}
