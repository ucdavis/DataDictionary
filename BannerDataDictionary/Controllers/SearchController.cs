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
                var query = conn.Query<LinkedServer>(@"EXEC usp_GetOracleLinkedServerNames");

                var linkedServers = query as IList<LinkedServer> ?? query.ToList();
                viewModel.Items = linkedServers.Select(x => new SelectListItem
                    {
                        Value = x.Name,
                        Text = x.Name
                    });
                viewModel.LinkedServers = linkedServers.ToList();

                return View(viewModel);
            }
        }

        [HttpPost]
       // public ActionResult Details(string searchString)
       public ActionResult Details(SearchModel model)
        {
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["MainDb"].ConnectionString))
            {
                var searchString = model.SearchString;
                var selectedServerNames = model.SelectedServersNames;
                var selectedServerNamesConcat = "";
                if (selectedServerNames.Any())
                {
                    foreach (var name in selectedServerNames)
                    {
                        selectedServerNamesConcat += name + ",";
                    }
                    selectedServerNamesConcat = selectedServerNamesConcat.Substring(0,
                                                                                    selectedServerNamesConcat.Length - 1);
                }
                else
                {
                    selectedServerNamesConcat = "DEFAULT";
                }

                    conn.Open();
                IList<SearchResult> results =
                    conn.Query<SearchResult>(@"SELECT * FROM dbo.udf_GetTableColumnCommentsResults(@searchString, @LinkedServerNames)", new { @searchString = searchString, @LinkedServerNames = selectedServerNamesConcat }).ToList();
                return View(results);
            }
            return View();
        }

    }
}
