using Models.Constants;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models
{
    public class StateRequest
    {
        public long StateId { get; set; }

        [Required(ErrorMessage = ValidationConstants.StateNameRequied_Msg)]
        [RegularExpression(ValidationConstants.StateNameRegExp, ErrorMessage = ValidationConstants.StateNameRegExp_Msg)]
        [MaxLength(ValidationConstants.StateName_MaxLength, ErrorMessage = ValidationConstants.StateName_MaxLength_Msg)]
        public string StateName { get; set; }
        public bool IsActive { get; set; }
    }

    public class SearchStateRequest
    {
        public PaginationParameters pagination { get; set; }
        public string StateName { get; set; }
        public Nullable<bool> IsActive { get; set; }
    }

    public class StateResponse : CreationDetails
    {
        public long StateId { get; set; }
        public string StateName { get; set; }
        public bool IsActive { get; set; }
    }

    public class ImportedStateDetails
    {
        public string StateName { get; set; }
        public string IsActive { get; set; }
    }
    public class StateDataValidationErrors
    {
        public string StateName { get; set; }
        public string IsActive { get; set; }
        public string ValidationMessage { get; set; }
    }
}
