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
      
                var loginId = User.Identity.Name;
                var bannerUserList = conn.Query(string.Format("SELECT LoginId FROM BannerLoginIds WHERE LoginId = '{0}'", loginId)).ToList();
                var includeBannerItems = bannerUserList.Count() == 1 ? true : false;
                var resultList =
                    conn.Query<LinkedServer>(
                        string.Format("EXEC usp_GetOracleLinkedServerNames @IncludeBannerItems = {0}",
                                      includeBannerItems)).ToList(); 
                                                               
                 return View(resultList);
            }
        }

        [AllowAnonymous]
        public ActionResult About()
        {
            ViewBag.Message = "About";
            return View();
        }

        [AllowAnonymous]
        public ActionResult Contact()
        {
            ViewBag.Message = "Contact";
            return View();
        }
    }
}
