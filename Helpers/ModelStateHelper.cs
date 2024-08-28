using Microsoft.AspNetCore.Mvc;
using Models;
using Models.Constants;
using System.ComponentModel.DataAnnotations;

namespace Helpers
{
    public static class ModelStateHelper
    {
        public static ResponseModel GetValidationErrorsList(ActionContext actionContext)
        {
            ResponseModel response = new ResponseModel();

            response.IsSuccess = false;
            response.Message = ErrorConstants.ValidationFailureError;

            response.Data = actionContext.ModelState
                    .Where(modelError => modelError.Value.Errors.Count > 0)
                    .Select(modelError => new ValidationErrorsModel()
                    {
                        Field = modelError.Key.IndexOf('.') > -1 ? modelError.Key.Split('.')[1] : modelError.Key,
                        ErrorMessage = modelError.Value?.Errors.FirstOrDefault()?.ErrorMessage
                    }).ToList();

            return response;
        }

        public static ResponseModel GetValidationErrorsList(object model)
        {
            ResponseModel response = new ResponseModel();

            response.IsSuccess = true;
            ValidationContext ctx = new ValidationContext(model, null, null);
            ICollection<ValidationResult> results = new List<ValidationResult>();

            if (!Validator.TryValidateObject(model, ctx, results, true))
            {
                response.Data = results.Select(modelError => new ValidationErrorsModel()
                {
                    Field = modelError.MemberNames.FirstOrDefault(),
                    ErrorMessage = modelError.ErrorMessage
                }).ToList();

                response.IsSuccess = false;
                response.Message = ErrorConstants.ValidationFailureError;
            }

            return response;
        }

        public static List<ResponseModel> GetValidationErrorsList(List<object> models)
        {
            List<ResponseModel> lstResponse = new List<ResponseModel>();
            ValidationContext ctx;
            ICollection<ValidationResult> results;
            ResponseModel response;

            foreach (object model in models)
            {
                ctx = new ValidationContext(model, null, null);
                results = new List<ValidationResult>();
                response = new ResponseModel();
                response.IsSuccess = true;

                if (!Validator.TryValidateObject(model, ctx, results, true))
                {
                    response.Data = results.Select(modelError => new ValidationErrorsModel()
                    {
                        Field = modelError.MemberNames.FirstOrDefault(),
                        ErrorMessage = modelError.ErrorMessage
                    }).ToList();

                    response.IsSuccess = false;
                    response.Message = ErrorConstants.ValidationFailureError;
                }

                lstResponse.Add(response);
            }

            return lstResponse;
        }
    }
}
