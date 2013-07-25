using UCDArch.Web.Controller;
using UCDArch.Web.Attributes;

namespace BannerDataDictionary.Controllers
{
    [Version(MajorVersion = 3)]
    //[ServiceMessage("BannerDataDictionary", ViewDataKey = "ServiceMessages", MessageServiceAppSettingsKey = "MessageService")]
    public abstract class ApplicationController : SuperController
    {
    }
}