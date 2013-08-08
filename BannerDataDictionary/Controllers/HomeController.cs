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
    public class HomeController : ApplicationController
    {
        public ActionResult Index()
        {
            ViewBag.Message = "Oracle Linked Servers";
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["MainDb"].ConnectionString))
            {
                conn.Open();
                var resultList = conn.Query<LinkedServer>(@"EXEC usp_GetOracleLinkedServerNames").ToList();
                return View(resultList);
            }
        }
    }
}
