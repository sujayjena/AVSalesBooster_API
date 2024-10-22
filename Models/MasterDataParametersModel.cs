using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace Models
{
    public class SelectListResponse
    {
        public long Value { get; set; }
        public string Text { get; set; }
    }

    public class CommonSelectListRequestModel
    {
        public bool? IsActive { get; set; }
    }

    public class StatesSelectListRequestModel : CommonSelectListRequestModel
    {

    }

    public class RegionSelectListRequestModel : CommonSelectListRequestModel
    {
        [Range(1, long.MaxValue, ErrorMessage = "State is required")]
        public long StateId { get; set; }
    }

    public class DistrictSelectListRequestModel : CommonSelectListRequestModel
    {
        [Range(1, long.MaxValue, ErrorMessage = "Region is required")]
        public long RegionId { get; set; }
    }

    public class AreaSelectListRequestModel : CommonSelectListRequestModel
    {
        [Range(1, long.MaxValue, ErrorMessage = "District is required")]
        public long DistrictId { get; set; }
    }

    public class CustomerSelectListRequestModel : CommonSelectListRequestModel
    {
        public long? CustomerTypeId { get; set; }
    }

    public class ReportingToEmpListParameters
    {
        public long RoleId { get; set; }
        public long? RegionId { get; set; }

        [DefaultValue(null)]
        public bool? IsActive { get; set; }
    }
}
