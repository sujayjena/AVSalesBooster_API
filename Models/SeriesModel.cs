using Models.Constants;
using System.ComponentModel.DataAnnotations;

namespace Models
{
    public class SeriesRequest
    {
        public long SeriesId { get; set; }

        [Required(ErrorMessage = ValidationConstants.SeriesNameRequied_Msg)]
        [RegularExpression(ValidationConstants.SeriesNameRegExp, ErrorMessage = ValidationConstants.SeriesNameRegExp_Msg)]
        [MaxLength(ValidationConstants.SeriesName_MaxLength, ErrorMessage = ValidationConstants.SeriesName_MaxLength_Msg)]
        public string SeriesName { get; set; }
        public bool IsActive { get; set; }
    }

    public class SeriesResponse : CreationDetails
    {
        public long SeriesId { get; set; }
        public string SeriesName { get; set; }
        public bool IsActive { get; set; }
    }
    public class SearchSeriesRequest
    {
        public PaginationParameters pagination { get; set; }
        public string SeriesName { get; set; }
        public Nullable<bool> IsActive { get; set; }
    }
    public class SeriesDataValidationErrors
    {
        public string SeriesName { get; set; }
        public string IsActive { get; set; }
        public string ValidationMessage { get; set; }
    }
    public class ImportedSeriesDetails
    {
        public string SeriesName { get; set; }
        public string IsActive { get; set; }
    }
}
