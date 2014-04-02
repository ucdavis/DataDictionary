using System;
using System.Collections;
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
    public class OwnersController : ApplicationController
    {
        public ActionResult Index(LinkedServer id)
        {
            if (id == null)
            {
                ViewBag.Message = "Error: Must provide a Linked Server and Database Owner";
                return RedirectToAction("Index", "Home", new {Message = "Must Select a Linked Server to continue!"});
            }
            else
            {
                var includeEmptyTables = id.IncludeEmptyTables ?? false;
                var linkedServerName = id.Name as string ?? "SIS";

                ViewBag.Message = linkedServerName + " Database Owners";

                using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["MainDb"].ConnectionString))
                {
                    conn.Open();

                    var loginId = User.Identity.Name;
                    var bannerUserList = conn.Query(string.Format("SELECT LoginId FROM BannerLoginIds WHERE LoginId = '{0}'", loginId)).ToList();
                    var includeBannerItems = bannerUserList.Count() == 1 ? true : false;

                    var databaseOwners = conn.Query<DatabaseOwner>(
                            @"EXEC usp_GetLinkedServerDatabaseOwnersAndTableCount @LinkedServerNames = @linkedServerName, @IncludeEmptyTables = @includeEmptyTables, @IncludeBannerItems = @includeBannerItems",
                            new
                                {
                                    @linkedServerName = linkedServerName,
                                    @includeEmptyTables = includeEmptyTables,
                                    @includeBannerItems = includeBannerItems
                                }).ToList();
                   
                    return View(databaseOwners);
                }
            }
        }
    }
}
