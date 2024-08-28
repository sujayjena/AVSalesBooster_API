using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace AVSalesBoosterAPI.CustomAttributes
{
    /// <summary>
    /// To configure request parameters for Swagger UI
    /// </summary>
    public class SwaggerCustomFilter : IOperationFilter
    {
        /// <inheritdoc/>
        public void Apply(OpenApiOperation operation, OperationFilterContext context)
        {
            string relativePath = context.ApiDescription.RelativePath ?? "";
            //bool isTokenRequired = true;

            //if (string.Equals(relativePath, "api/Login/LoginByEmail", StringComparison.OrdinalIgnoreCase))
            //{
            //    isTokenRequired = false;
            //}

            //operation.Parameters.Add(new OpenApiParameter
            //{
            //    Name = "Authorization",
            //    In = ParameterLocation.Header,
            //    Description = "Session Token",
            //    Required = isTokenRequired
            //});

            if (string.Equals(relativePath, "api/Profile/SaveEmployeeDetails", StringComparison.OrdinalIgnoreCase))
            {
                operation.Parameters.Clear();

                operation.Parameters.Add(new OpenApiParameter
                {
                    Name = "parameter",
                    In = ParameterLocation.Query,
                    Description = "{\r\n    \"EmployeeId\": 0,\r\n    \"EmployeeName\": \"\",\r\n    \"EmployeeCode\": \"\",\r\n    \"EmailId\": \"\",\r\n    \"MobileNumber\": \"\",\r\n    \"RoleId\": 1,\r\n    \"ReportingTo\": null,\r\n    \"Address\": \"\",\r\n    \"StateId\": 1,\r\n    \"RegionId\": 1,\r\n    \"DistrictId\": 1,\r\n    \"AreaId\": 1,\r\n    \"Pincode\": \"\",\r\n    \"DateOfBirth\": \"2000-01-10\",\r\n    \"DateOfJoining\": \"2023-08-10\",\r\n    \"EmergencyContactNumber\": \"\",\r\n    \"BloodGroupId\": null,\r\n    \"IsWebUser\": true,\r\n    \"IsMobileUser\": true,\r\n    \"IsActive\": true,\r\n    \"InitialPassword\": \"\",\r\n    \"MobileUniqueId\": \"\",\r\n    \"IsToDeleteProfilePic\": false,\r\n    \"IsToDeleteAdharCard\": false,\r\n    \"IsToDeletePanCard\": false\r\n}",
                    Required = true,
                    Schema = new OpenApiSchema
                    {
                        Type = "string",
                        Format = "json"
                    }
                });

                //operation.Parameters.Add(new OpenApiParameter
                //{
                //    Name = "profilePicture",
                //    In = ParameterLocation.Query,
                //    Description = "Upload File",
                //    Required = false,
                //    Schema = new OpenApiSchema
                //    {
                //        Type = "file",
                //        Format = "binary"
                //    }
                //});
            }

            if (string.Equals(relativePath, "api/Visit/SaveVisitDetails", StringComparison.OrdinalIgnoreCase))
            {
                operation.Parameters.Clear();

                operation.Parameters.Add(new OpenApiParameter
                {
                    Name = "parameter",
                    In = ParameterLocation.Query,
                    Description = "{\r\n  \"VisitId\": 0,\r\n  \"EmployeeId\": 1,\r\n  \"VisitDate\": \"2023-09-01\",\r\n \"HasVisited\": true,\r\n  \"CustomerTypeId\": 1,\r\n  \"CustomerId\": 1,\r\n  \"StateId\": 1,\r\n  \"RegionId\": 1,\r\n  \"DistrictId\": 1,\r\n  \"AreaId\": 1,\r\n  \"Address\": \"Temp Address\",\r\n  \"ContactPerson\": \"CP One\",\r\n  \"ContactNumber\": \"1236548920\",\r\n  \"EmailId\": \"test@test.com\",\r\n  \"NextActionDate\": \"2023-09-10\",\r\n  \"Latitude\": 10.0,\r\n  \"Longitude\": 20.0,\r\n  \"IsActive\": true,\r\n  \"VisitStatusId\": 1,\r\n  \"Remarks\": [\r\n    {\r\n      \"VisitRemarkId\": 0,\r\n      \"Remarks\": \"Demo Remark\"\r\n    }\r\n  ],\r\n  \"VisitExistingPhotosList\":[\r\n\t{\r\n\t\t\"VisitPhotoId\":0,\r\n\t\t\"UploadedFileName\":\"\",\r\n\t\t\"SavedFileName\":\"\"\r\n\t}\r\n  ]\r\n}",
                    Required = true,
                    Schema = new OpenApiSchema
                    {
                        Type = "string",
                        Format = "json"
                    }
                });

                //operation.Parameters.Add(new OpenApiParameter
                //{
                //    Name = "VisitPictures",
                //    In = ParameterLocation.Query,
                //    Description = "Upload File",
                //    Required = false,
                //    Schema = new OpenApiSchema
                //    {
                //        Type = "file",
                //        Format = "binary"
                //    }
                //});
            }
        }
    }
}
