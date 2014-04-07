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
        public static string BannerMessage = "<h4>Access to the Banner meta-data is limited to those individuals with existing individual, personal, non-departmental/non-application third-party* accounts or to those individuals whom have specifically requested Banner meta-data access via e-mail to: <a href=\"mailto:banner-sa@ucdavis.edu?subject=Banner Meta-Data Schema Access Request&body=Please setup the following UC Davis Login, i.e. Kerberos, IDs to the named profiles and associate user to profiles for the individuals listed below.  This is solely for the purpose of allowing access to the Banner Schema meta-data by way of the CAES Data Dictionary application.  No other Banner access is requested, intended or implied.  Thank you.  I have included the College, unit name, user\'s full name, title, kerberos ID, e-mail address and phone number, as well as supervisor\'s full name, title, e-mail address, phone number, plus the business purpose.\">banner-sa@ucdavis.edu</a>.</h4>" +
             "<br /><p>*Note: A Banner third-party account is a Banner database access account created for someone or something outside of the Banner team.&nbsp;&nbsp;An individual, personal account may have been requested by a single application developer in another unit, and would have been tied directly to that individual\'s UCD Login/Kerberos Id.&nbsp;&nbsp;Third-party <i>application</i> or <i>departmental</i> accounts are different because they are typically created for use by an application and/or for direct database access by a group of developers in a particular unit; therefore, the system has no way of knowing of which individual developers may be using the account, and must specifically request Banner meta-data access as outlined above.</p>";
                                    
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

                if (!includeBannerItems)
                    TempData["Message"] = BannerMessage;
            
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
