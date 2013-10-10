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
                    //IList<DatabaseOwner> databaseOwners = conn.Query<DatabaseOwner>(@"EXEC usp_GetLinkedServerDatabaseOwnersAndTableCount @LinkedServerNames ='" + linkedServerName + "', @IncludeEmptyTables = " + includeEmptyTables).ToList();
                    IList<DatabaseOwner> databaseOwners = conn.Query<DatabaseOwner>(@"EXEC usp_GetLinkedServerDatabaseOwnersAndTableCount @LinkedServerNames = @linkedServerName, @IncludeEmptyTables = @includeEmptyTables", new { @linkedServerName = linkedServerName, @includeEmptyTables = includeEmptyTables }).ToList();

                    return View(databaseOwners);
                }
            }
        }
    }
}
