using System.ComponentModel;
using System.Text.Json.Serialization;

namespace Models
{
    public class PaginationParameters
    {
        public int PageNo { get; set; }
        public int PageSize { get; set; }

        [JsonIgnore]
        public int Total { get; set; }

        [DefaultValue("")]
        public string SortBy { get; set; }

        [DefaultValue("")]
        public string OrderBy { get; set; }
    }
}
