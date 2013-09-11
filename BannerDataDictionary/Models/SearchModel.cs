using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace BannerDataDictionary.Models
{
    public class SearchModel
    {
        [Display(Name = "Enter text or keyword(s) to search for:")]
        public string SearchString { get; set; }
        public string[] SelectedServerNames { get; set; } //This is what's populated when a user selects (a) linked server(s).
        public ICollection<LinkedServer> LinkedServers { get; set; }
       
        public SearchModel()
        {
            SearchString = string.Empty;
        }
    }
}