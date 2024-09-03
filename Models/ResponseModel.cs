using System.ComponentModel;

namespace Models
{
    public class ResponseModel
    {
        [DefaultValue(0)]
        public long Id { get; set; }

        public bool IsSuccess { get; set; }
        public string Message { get; set; }

        [DefaultValue(0)]
        public long Total { get; set; }
        public object Data { get; set; }
    }
}
