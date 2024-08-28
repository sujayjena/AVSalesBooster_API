using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;

namespace Helpers
{
    public interface IFileManager
    {
        string UploadDocumentsBase64ToFile(string base64String, string folderPath, string? fileName);
        byte[]? GetFormatFileFromPath(string fileName);

        string UploadProfilePicture(IFormFile file);
        byte[]? GetProfilePicture(string imageFileName);
        string? GetProfilePictureFile(string fileName);


        string UploadEmpDocuments(IFormFile file);
        byte[]? GetEmpDocuments(string fileName);
        string? GetEmpDocumentsFile(string fileName);


        string UploadCustomerDocuments(IFormFile file);
        byte[]? GetCustomerDocuments(string fileName);
        string? GetCustomerDocumentsFile(string fileName);


        string UploadVisitDocuments(IFormFile file);
        byte[]? GetVisitDocuments(string fileName);
        string? GetVisitDocumentsFile(string fileName);

        string UploadDesignFiles(IFormFile file);
        byte[]? GetDesignFiles(string fileName);
        string? GetDesignDcoumentFile(string fileName);

        string UploadCatalogDocuments(IFormFile file);
        byte[]? GetCatalogDocuments(string fileName);
        string? GetCatalogDocumentsFile(string fileName);

        string? GetSolutionFeatureFile(string fileName);
        string? GetSolutionImageFile(string fileName);
        string? GetProjectCaseStudyFile(string fileName);

        string UploadCatalogRelatedDocuments(IFormFile file);
        byte[]? GetCatalogRelatedDocuments(string fileName);

        string UploadProjectDocuments(IFormFile file);
        byte[]? GetProjectDocuments(string fileName);
        string? GetProjectDocumentsFile(string fileName);
    }

    public class FileManager : IFileManager
    {
        private readonly IHostingEnvironment _environment;
        public FileManager(IHostingEnvironment environment)
        {
            _environment = environment;
        }

        public string? UploadDocumentsBase64ToFile(string base64String, string folderPath, string? fileName)
        {
            string sFileName = string.Empty;
            try
            {
                var extentioName = Path.GetExtension(fileName);

                string newfileName = $"{Guid.NewGuid()}" + extentioName;
                string fileDirectory = $"{_environment.ContentRootPath}" + folderPath;
                string fileSavePath = $"{_environment.ContentRootPath}" + folderPath + newfileName;

                if (!Directory.Exists(fileDirectory))
                {
                    Directory.CreateDirectory(fileDirectory);
                }

                var byteData = Convert.FromBase64String(base64String);
                File.WriteAllBytes(fileSavePath, byteData);

                sFileName = newfileName;
            }
            catch (Exception ex)
            {
            }

            return sFileName;
        }

        public byte[]? GetFormatFileFromPath(string fileNameWithExtention)
        {
            byte[]? result = null;
            string imageWithFullPath = $"{_environment.ContentRootPath}\\FormatFiles\\{fileNameWithExtention}";

            if (File.Exists(imageWithFullPath))
            {
                result = File.ReadAllBytes(imageWithFullPath);
            }

            return result;
        }

        private string SaveFileToPath(string folderPath, IFormFile postedFile)
        {
            string fileName = $"{Guid.NewGuid()}{new FileInfo(postedFile.FileName).Extension}";
            string fileSaveLocation = $"{folderPath}{fileName}";

            if (!Directory.Exists(folderPath))
            {
                Directory.CreateDirectory(folderPath);
            }

            using (Stream fileStream = new FileStream(fileSaveLocation, FileMode.Create))
            {
                postedFile.CopyTo(fileStream);
            }

            return fileName;
        }
        
        public string UploadProfilePicture(IFormFile file)
        {
            string folderPath = $"{_environment.ContentRootPath}\\Uploads\\ProfilePicture\\";
            string fileName = SaveFileToPath(folderPath, file);
            return fileName;
        }

        public byte[]? GetProfilePicture(string imageFileName)
        {
            byte[]? result = null;
            string imageWithFullPath = $"{_environment.ContentRootPath}\\Uploads\\ProfilePicture\\{imageFileName}";

            if (File.Exists(imageWithFullPath))
            {
                result = File.ReadAllBytes(imageWithFullPath);
            }

            return result;
        }
        public string? GetProfilePictureFile(string fileName)
        {
            string fileWithFullPath = "\\Uploads\\ProfilePicture\\" + fileName;
            return fileWithFullPath;
        }


        public string UploadEmpDocuments(IFormFile file)
        {
            string folderPath = $"{_environment.ContentRootPath}\\Uploads\\Documents\\";
            string fileName = SaveFileToPath(folderPath, file);
            return fileName;
        }
        public string? GetEmpDocumentsFile(string fileName)
        {
            string fileWithFullPath = "\\Uploads\\Documents\\" + fileName;
            return fileWithFullPath;
        }

        public string UploadCustomerDocuments(IFormFile file)
        {
            string folderPath = $"{_environment.ContentRootPath}\\Uploads\\Customers\\";
            string fileName = SaveFileToPath(folderPath, file);
            return fileName;
        }

        public byte[]? GetCustomerDocuments(string fileName)
        {
            byte[]? result = null;
            string fileWithFullPath = $"{_environment.ContentRootPath}\\Uploads\\Customers\\{fileName}";

            if (File.Exists(fileWithFullPath))
            {
                result = File.ReadAllBytes(fileWithFullPath);
            }

            return result;
        }

        public string? GetCustomerDocumentsFile(string fileName)
        {
            string fileWithFullPath = "\\Uploads\\Customers\\" + fileName;
            return fileWithFullPath;
        }


        public byte[]? GetEmpDocuments(string fileName)
        {
            byte[]? result = null;
            string fileWithFullPath = $"{_environment.ContentRootPath}\\Uploads\\Documents\\{fileName}";

            if (File.Exists(fileWithFullPath))
            {
                result = File.ReadAllBytes(fileWithFullPath);
            }

            return result;
        }

        public string UploadVisitDocuments(IFormFile file)
        {
            string folderPath = $"{_environment.ContentRootPath}\\Uploads\\VisitPhotos\\";
            string fileName = SaveFileToPath(folderPath, file);
            return fileName;
        }

        public byte[]? GetVisitDocuments(string fileName)
        {
            byte[]? result = null;
            string fileWithFullPath = $"{_environment.ContentRootPath}\\Uploads\\VisitPhotos\\{fileName}";

            if (File.Exists(fileWithFullPath))
            {
                result = File.ReadAllBytes(fileWithFullPath);
            }

            return result;
        }
        public string? GetVisitDocumentsFile(string fileName)
        {
            string fileWithFullPath = "\\Uploads\\VisitPhotos\\" + fileName;
            return fileWithFullPath;
        }

        public string UploadDesignFiles(IFormFile file)
        {
            string folderPath = $"{_environment.ContentRootPath}\\Uploads\\DesignFiles\\";
            string fileName = SaveFileToPath(folderPath, file);
            return fileName;
        }

        public byte[]? GetDesignFiles(string fileName)
        {
            byte[]? result = null;
            string fileWithFullPath = $"{_environment.ContentRootPath}\\Uploads\\DesignFiles\\{fileName}";

            if (File.Exists(fileWithFullPath))
            {
                result = File.ReadAllBytes(fileWithFullPath);
            }

            return result;
        }

        public string? GetDesignDcoumentFile(string fileName)
        {
            string fileWithFullPath = "\\Uploads\\DesignFiles\\" + fileName;
            return fileWithFullPath;
        }

        public string UploadCatalogDocuments(IFormFile file)
        {
            string folderPath = $"{_environment.ContentRootPath}\\Uploads\\Catalog\\";
            string fileName = SaveFileToPath(folderPath, file);
            return fileName;
        }

        public byte[]? GetCatalogDocuments(string fileName)
        {
            byte[]? result = null;
            string fileWithFullPath = $"{_environment.ContentRootPath}\\Uploads\\Catalog\\{fileName}";

            if (File.Exists(fileWithFullPath))
            {
                result = File.ReadAllBytes(fileWithFullPath);
            }

            return result;
        }

        public string? GetCatalogDocumentsFile(string fileName)
        {
            string fileWithFullPath = "\\Uploads\\Catalog\\" + fileName;
            return fileWithFullPath;
        }

        public string? GetSolutionFeatureFile(string fileName)
        {
            string fileWithFullPath = "\\Uploads\\Industry\\Feature\\" + fileName;
            return fileWithFullPath;
        }

        public string? GetSolutionImageFile(string fileName)
        {
            string fileWithFullPath = "\\Uploads\\Industry\\Images\\" + fileName;
            return fileWithFullPath;
        }

        public string? GetProjectCaseStudyFile(string fileName)
        {
            string fileWithFullPath = "\\Uploads\\Project\\CaseStudy\\" + fileName;
            return fileWithFullPath;
        }

        public string UploadCatalogRelatedDocuments(IFormFile file)
        {
            string folderPath = $"{_environment.ContentRootPath}\\Uploads\\CatalogRelated\\";
            string fileName = SaveFileToPath(folderPath, file);
            return fileName;
        }

        public byte[]? GetCatalogRelatedDocuments(string fileName)
        {
            byte[]? result = null;
            string fileWithFullPath = $"{_environment.ContentRootPath}\\Uploads\\CatalogRelated\\{fileName}";

            if (File.Exists(fileWithFullPath))
            {
                result = File.ReadAllBytes(fileWithFullPath);
            }

            return result;
        }

        public string UploadProjectDocuments(IFormFile file)
        {
            string folderPath = $"{_environment.ContentRootPath}\\Uploads\\Project\\";
            string fileName = SaveFileToPath(folderPath, file);
            return fileName;
        }

        public byte[]? GetProjectDocuments(string fileName)
        {
            byte[]? result = null;
            string fileWithFullPath = $"{_environment.ContentRootPath}\\Uploads\\Project\\{fileName}";

            if (File.Exists(fileWithFullPath))
            {
                result = File.ReadAllBytes(fileWithFullPath);
            }

            return result;
        }
        public string? GetProjectDocumentsFile(string fileName)
        {
            string fileWithFullPath = "\\Uploads\\Project\\" + fileName;
            return fileWithFullPath;
        }
    }
}
