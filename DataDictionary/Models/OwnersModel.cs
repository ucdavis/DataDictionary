using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace BannerDataDictionary.Models
{
    public class OwnersModel
    {
        public LinkedServer LinkedServer { get; set; }
        public String LinkedServerName { get; set; }
        public IList<DatabaseOwner> Owners { get; set; }
    }
}