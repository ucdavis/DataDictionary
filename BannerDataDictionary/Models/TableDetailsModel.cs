using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace BannerDataDictionary.Models
{
    public class TableDetailsModel
    {
        public string LinkedServerName { get; set; }
        public string TableName { get; set; }
        public string Owner { get; set; }
        public string TableComments { get; set; }
        public string NumRows { get; set; }
        public string TableType { get; set; }
        public IList<Column> Columns { get; set; }
        public IList<DapperIndex> Indexes { get; set; }
        public IList<DapperConstraint> Constraints { get; set; } 
    }
}