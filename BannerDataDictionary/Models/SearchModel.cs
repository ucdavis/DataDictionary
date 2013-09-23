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
        [Required, Display(Name = "Search String", Prompt = "Enter keyword(s) or text string that can be part of a Table Name, Column Name, or be present in the comment fields:")]
        public string SearchString { get; set; }
        public string[] SelectedServerNames { get; set; } //This is what's populated when a user selects (a) linked server(s).
        [Display(Name = "Linked Server(s)")]
        public ICollection<LinkedServer> LinkedServers { get; set; }
       
        public SearchModel()
        {
            SearchString = string.Empty;
        }
    }
}