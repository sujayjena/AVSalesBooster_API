using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace AVSalesBoosterAPI.CustomAttributes
{
    /// <summary>
    /// Custom attribute for swagger to change schema for file or binary data
    /// </summary>
    public class SwaggerFormDataSchemaFilter : ISchemaFilter
    {
        /// <summary>
        /// Apply overridden method
        /// </summary>
        /// <param name="schema"></param>
        /// <param name="context"></param>
        public void Apply(OpenApiSchema schema, SchemaFilterContext context)
        {
            if (context.Type == typeof(IFormFile))
            {
                schema.Type = "string";
                schema.Format = "binary";
            }
        }
    }
}
