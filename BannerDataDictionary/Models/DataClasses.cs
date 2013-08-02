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

    public class Column
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

    public class SimpleColumn
    {
        public String ColumnName { get; set; }
        public String ColumnPosition { get; set; }
    }

    public class Index
    {
        public String IndexName { get; set; }
        public String ColumnName { get; set; }
        public String SortOrder { get; set; }
        public String Uniqueness { get; set; }
        public String DistinctKeys { get; set; }
    }

    public class DapperIndex
    {
        public String IndexName { get; set; }
        public String Owner { get; set; }
        public String TableName { get; set; }
        public String ColumnName { get; set; }
        public String ColumnPosition { get; set; }
        public String SortOrder { get; set; }
        public String Uniqueness { get; set; }
        public String DistinctKeys { get; set; }
    }

    public class Constraint
    {
        public String ConstraintName { get; set; }
        public String Owner { get; set; }
        public String TableName { get; set; }
        public IList<SimpleColumn> Columns { get; set; }
        public String Status { get; set; }
        public String ConstraintType { get; set; }
    }

    public class DapperConstraint
    {
        public String ConstraintName { get; set; }
        public String Owner { get; set; }
        public String TableName { get; set; }
        public String ColumnName { get; set; }
        public String ColumnPosition { get; set; }
        public String Status { get; set; }
        public String ConstraintType { get; set; }
    }
}