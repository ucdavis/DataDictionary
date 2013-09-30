using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using MvcContrib.FluentHtml.Elements;


namespace BannerDataDictionary.Models
{
    public class SearchModel
    {
        [Required, Display(Name = "Search String", Prompt = "Enter keyword(s) or text string that can be part of a Table Name, Column Name, or be present in the comment fields:")]
        public string SearchString { get; set; }
        public string[] SelectedServerNames { get; set; } //This is what's populated when a user selects (a) linked server(s).
        
        [Display(Name = "Linked Server(s)")]
        public ICollection<LinkedServer> LinkedServers { get; set; }

        [Display(Name = "Search for Table(s)")]
        public bool SearchTables { get; set; }
        [Display(Name = "Search for Column(s)")]
        public bool SearchColumns { get; set; }
        [Display(Name = "Search for Comment(s)")]
        public bool SearchComments { get; set; }

        [Display(Name = "Select the Item(s) to match")]
        public ICollection<SimpleCheckbox> SearchItems { get; set; } 

        public SearchModel()
        {
            SearchString = string.Empty;
            SearchItems = new List<SimpleCheckbox>
                {
                     new SimpleCheckbox{ Id = 1, Name = "SearchTables", Prompt = "Tables" },
                     new SimpleCheckbox{ Id = 2, Name = "SearchColumns", Prompt = "Columns" },
                     new SimpleCheckbox{ Id = 3, Name = "SearchComments", Prompt = "Comments" }
                };
        }
    }

    public class SimpleCheckbox
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Prompt { get; set; }
    }
}