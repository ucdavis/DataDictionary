using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
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
            var viewModel = new SearchModel();

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["MainDb"].ConnectionString))
            {
                conn.Open();

                var loginId = User.Identity.Name;
                var bannerUserList = conn.Query(string.Format("SELECT LoginId FROM BannerLoginIds WHERE LoginId = '{0}'", loginId)).ToList();
                var includeBannerItems = bannerUserList.Count() == 1 ? true : false;

                viewModel.LinkedServers = conn.Query<LinkedServer>(string.Format("EXEC usp_GetOracleLinkedServerNames @IncludeBannerItems = {0}", includeBannerItems)).ToList();

                return View(viewModel);
            }
        }

        [HttpPost]
        public ActionResult Details(SearchModel model)
        {
            if (ModelState.IsValid)
            {
                using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["MainDb"].ConnectionString))
                {
                    var searchString = model.SearchString;
                    var searchTables = model.SearchTables;
                    var searchColumns = model.SearchColumns;
                    var searchComments = model.SearchComments;
                    var selectedServerNames = model.SelectedServerNames;
                        //This what's populated when a user selects (a) linked server(s).
                    var selectedServerNamesString = "";
                    if (selectedServerNames != null && selectedServerNames.Any())
                    {
                        selectedServerNamesString = selectedServerNames.Aggregate(selectedServerNamesString,
                                                                                  (current, name) =>
                                                                                  current + (name + ","));
                        selectedServerNamesString = selectedServerNamesString.Substring(0,
                                                                                        selectedServerNamesString.Length -
                                                                                        1);
                    }

                    conn.Open();

                    var loginId = User.Identity.Name;
                    var bannerUserList = conn.Query(string.Format("SELECT LoginId FROM BannerLoginIds WHERE LoginId = '{0}'", loginId)).ToList();
                    var includeBannerItems = bannerUserList.Count() == 1 ? true : false;

                    var results =
                        conn.Query<SearchResult>(
                            @"SELECT * FROM dbo.udf_GetTableColumnCommentsResults(@searchString, @LinkedServerNames, 
                                @SearchTables, @SearchColumns, @SearchComments, @IncludeBannerItems)",
                            new {@searchString = searchString, @LinkedServerNames = selectedServerNamesString,
                                 @SearchTables = searchTables,
                                 @SearchColumns = searchColumns,
                                 @SearchComments = searchComments,
                                 @IncludeBannerItems = includeBannerItems 
                            }).ToList();

                    if (results.Count == 1)
                    {
                        // means we got back a single matching table => jump to table details page:
                        var result = results.FirstOrDefault();
                        return RedirectToAction("Details", "Tables", new Table { LinkedServerName = result.LinkedServerName, Owner = result.Owner, TableName = result.TableName });
                    }
                    return View(results);
                }
            }
            return View(model);
        }
    }
}
