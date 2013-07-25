using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace BannerDataDictionary.Models
{
    public class DataClasses
    {
    }

    public class Table
    {
        public String Owner { get; set; }
        public String TableName { get; set; }
        public String Comments { get; set; }
        public String NumRows { get; set; }
    }

    public class Columns
    {
        public String Owner { get; set; }
        public String TableName { get; set; }
        public String ColumnName { get; set; }
        public String ColumnComments { get; set; }
        public String DataType { get; set; }
        public String DataLength { get; set; }
        public String DataPrecision { get; set; }
        public String DataScale { get; set; }
        public String Nullable { get; set; }
        public String ColumnId { get; set; }
    }

}