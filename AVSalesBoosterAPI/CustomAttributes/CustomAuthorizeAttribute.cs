using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Models;

namespace AVSalesBoosterAPI.CustomAttributes
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
    public class CustomAuthorizeAttribute : Attribute, IAuthorizationFilter
    {
        public void OnAuthorization(AuthorizationFilterContext context)
        {
            UsersLoginSessionData? sessionData;

            // skip authorization if action is decorated with [AllowAnonymous] attribute
            bool allowAnonymous = context.ActionDescriptor.EndpointMetadata.OfType<AllowAnonymousAttribute>().Any();

            if (allowAnonymous)
                return;

            // authorization
            sessionData = (UsersLoginSessionData?)context.HttpContext.Items["SessionData"]!;

            // Here also needs to authorized users based on Roles and Access like Add, Update, View or Delete
            if (sessionData == null)
            {
                // not logged in or role not authorized
                context.Result = new JsonResult(new ResponseModel 
                { 
                    IsSuccess = false,
                    Message = "Inactive Session! Either you are not logged-in or session is expired, please do login and try again"
                })
                { 
                    StatusCode = StatusCodes.Status401Unauthorized 
                };
            }
        }
    }
}
