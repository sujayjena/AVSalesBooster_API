using Microsoft.AspNetCore.Http;
using Models.Constants;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models
{
    public class ProjectRequest
    {
        public ProjectRequest()
        {
            caseStudyList = new List<ProjectCaseStudyRequest>();
            clienteleList = new List<ProjectClienteleRequest>();
        }
        public long ProjectId { get; set; }

        [Required(ErrorMessage = ValidationConstants.ProjectNameRequied_Msg)]
        public string ProjectName { get; set; }

        public string Description { get; set; }

        [Required(ErrorMessage = ValidationConstants.LaunchDateRequied_Msg)]
        public DateTime CompletionDate { get; set; }

        [DefaultValue("")]
        public string ProjectFileName { get; set; }

        [DefaultValue("")]
        public string ProjectSavedFileName { get; set; }

        //public IFormFile ProjectFile { get; set; }

        [DefaultValue("")]
        public string? Project_Base64 { get; set; }

        public bool IsActive { get; set; }

        public List<ProjectCaseStudyRequest> caseStudyList { get; set; }
        public List<ProjectClienteleRequest> clienteleList { get; set; }
    }
    public class SearchProjectRequest
    {
        public PaginationParameters pagination { get; set; }

        [DefaultValue("")]
        public string ValueForSearch { get; set; } = null;
        public Nullable<bool> IsActive { get; set; }
    }
    public class ProjectResponse : CreationDetails
    {
        public long ProjectId { get; set; }
        public string ProjectName { get; set; }
        public string Description { get; set; }
        public DateTime CompletionDate { get; set; }
        public string ProjectFileName { get; set; }
        public string ProjectSavedFileName { get; set; }
        public string ProjectFileUrl { get; set; }
        public bool IsActive { get; set; }
    }
    public class ProjectDetailsResponse : CreationDetails
    {
        public long ProjectId { get; set; }
        public string ProjectName { get; set; }
        public string Description { get; set; }
        public DateTime CompletionDate { get; set; }
        public string ProjectFileName { get; set; }
        public string ProjectSavedFileName { get; set; }
        public byte[] ProjectFile { get; set; }
        public string ProjectFileUrl { get; set; }
        public bool IsActive { get; set; }
        public List<ProjectCaseStudyResponse> caseStudyList { get; set; }
        public List<ProjectClienteleResponse> clienteleList { get; set; }
    }

    public class ProjectCaseStudyRequest
    {
        public long ProjectCaseStudyId { get; set; }
        public long ProjectId { get; set; }

        [DefaultValue("")]
        public string? CaseStudyFileName { get; set; }

        [DefaultValue("")]
        public string? CaseStudySavedFileName { get; set; }

        [DefaultValue("")]
        public string? CaseStudy_Base64 { get; set; }
        public bool? IsActive { get; set; }
    }

    public class SearchProjectCaseStudy_ClienteleRequest
    {
        public PaginationParameters pagination { get; set; }
        public string SearchValue { get; set; }
        public Nullable<bool> IsActive { get; set; }
        public long ProjectId { get; set; }
    }

    public class ProjectCaseStudyResponse : CreationDetails
    {
        public long ProjectCaseStudyId { get; set; }
        public long ProjectId { get; set; }
        public string CaseStudyFileName { get; set; }
        public string CaseStudySavedFileName { get; set; }
        public string CaseStudyFileUrl { get; set; }
        public bool IsActive { get; set; }
    }

    public class ProjectClienteleRequest
    {
        public long ProjectClienteleId { get; set; }
        public long ProjectId { get; set; }
        public long CountryId { get; set; }
        public long IndustryId { get; set; }
        public bool? IsActive { get; set; }
    }

    public class ProjectClienteleResponse : CreationDetails
    {
        public long ProjectClienteleId { get; set; }
        public long ProjectId { get; set; }
        public long CountryId { get; set; }
        public string CountryName { get; set; }
        public long IndustryId { get; set; }
        public string IndustryName { get; set; }
        public bool IsActive { get; set; }
    }
}
