using Models.Constants;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models
{
    public class VisitTypeRequest
    {
        public long VisitTypeId { get; set; }
        public string? VisitTypeName { get; set; }
        public bool? IsActive { get; set; }
    }

    public class VisitTypeResponse : CreationDetails
    {
        public long VisitTypeId { get; set; }
        public string VisitTypeName { get; set; }
        public bool IsActive { get; set; }
    }

    public class SearchVisitTypeRequest
    {
        public PaginationParameters pagination { get; set; }
        public string VisitTypeName { get; set; }
        public Nullable<bool> IsActive { get; set; }
    }
    public class VisitTypeDataValidationErrors
    {
        public string VisitTypeName { get; set; }
        public string IsActive { get; set; }
        public string ValidationMessage { get; set; }
    }
    public class ImportedVisitTypeDetails
    {
        public string VisitTypeName { get; set; }
        public string IsActive { get; set; }
    }
}

