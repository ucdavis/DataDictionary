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
    public class SearchController : ApplicationController
    {
        //
        // GET: /Search/

        public ActionResult Index()
        {
            return View();
        }

        public ActionResult Details(string searchString)
        {
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["MainDb"].ConnectionString))
            {
                conn.Open();
                IList<SearchResult> results =
                    conn.Query<SearchResult>(@"SELECT * FROM dbo.udf_GetTableColumnCommentsResults(@searchString)", new { @searchString = searchString}).ToList();
                return View(results);
            }
            return View();
        }

    }
}
