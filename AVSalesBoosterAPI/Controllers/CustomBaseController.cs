using AVSalesBoosterAPI.CustomAttributes;
using Microsoft.AspNetCore.Mvc;

namespace AVSalesBoosterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [CustomAuthorize]
    public class CustomBaseController : ControllerBase
    {
    }
}
