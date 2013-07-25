using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace BannerDataDictionary.Models
{
    public class TableDetailsModel
    {
        public string TableName { get; set; }
        public string Owner { get; set; }
        public string TableComments { get; set; }
        public string NumRows { get; set; }
        public IList<Columns> Columns { get; set; }
    }
}