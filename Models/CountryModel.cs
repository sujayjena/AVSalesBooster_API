using Models.Constants;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models
{
    public class CountryRequest
    {
        public long CountryId { get; set; }
        public string CountryName { get; set; }
        public bool IsActive { get; set; }
    }

    public class SearchCountryRequest
    {
        public PaginationParameters pagination { get; set; }
        public string CountryName { get; set; }
        public Nullable<bool> IsActive { get; set; }
    }

    public class CountryResponse : CreationDetails
    {
        public long CountryId { get; set; }
        public string CountryName { get; set; }
        public bool IsActive { get; set; }
    }
}
