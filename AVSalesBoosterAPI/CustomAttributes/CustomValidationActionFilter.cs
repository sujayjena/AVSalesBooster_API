using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Models;
using Models.Constants;

namespace AVSalesBoosterAPI.CustomAttributes
{
    public class CustomValidationActionFilter : Attribute
    {
        public CustomValidationActionFilter() 
        { 
        
        }
        public void OnActionExecuted(ActionExecutedContext context)
        {
            throw new NotImplementedException();
        }

        public void OnActionExecuting(ActionExecutingContext context)
        {
            ResponseModel responseModel = new ResponseModel();

            // we can even *still* use model state properly…
            if (!context.ModelState.IsValid)
            {

                responseModel.IsSuccess = false;
                responseModel.Message = ErrorConstants.ValidationFailureError;
                responseModel.Data = "{ " + string.Join(", ", context.ModelState.Keys
                .SelectMany(key => context.ModelState[key]!.Errors
                .Select(x => "\"" + key + "\":\"" + x.ErrorMessage + "\""))) + " }";

                // setting the result shortcuts the pipeline, so the action is never executed
                context.Result = new JsonResult(responseModel);
            }
            
        }
    }
}
