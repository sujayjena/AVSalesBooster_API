using System.Text.Json;

namespace Helpers
{
    public static class JsonObjectHelper
    {
        public static string ExceptionJson(this Exception ex)
        {
            string json=string.Empty;
            JsonSerializerOptions options = new(JsonSerializerOptions.Default);
            options.Converters.Add(new CustomExceptionConverter());
            json = JsonSerializer.Serialize(ex, options);
            return json;
        }
    }
}
