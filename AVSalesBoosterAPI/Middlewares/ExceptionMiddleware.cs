using Helpers;
using Microsoft.Extensions.Options;
using Models;
using Models.Constants;
using System.Net;
using System.Text;
using System.Text.Json;

namespace AVSalesBoosterAPI.Middlewares
{
    public class ExceptionMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ExceptionMiddleware> _logger;
        private readonly IHostEnvironment _environment;
        private readonly AppSettings _appSettings;
        private ResponseModel _responseError;

        public ExceptionMiddleware(RequestDelegate next, ILogger<ExceptionMiddleware> logger, IHostEnvironment environment, IOptions<AppSettings> appSettings)
        {
            _next = next;
            _logger = logger;
            _environment = environment;
            _appSettings = appSettings.Value;
            _responseError = new ResponseModel();
        }

        public async Task Invoke(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                context.Response.ContentType = "application/json";
                context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;

                await WriteErrorLog(context, ex);
                
                _responseError.IsSuccess = false;

                if (_environment.IsDevelopment())
                {
                    _responseError.Message = ex.Message;
                    _responseError.Data = ex.ExceptionJson();
                }
                else
                {
                    _responseError.Message = ErrorConstants.InternalServerError;
                    _responseError.Data = ex.Message;
                }

                await context.Response.WriteAsync(JsonSerializer.Serialize(_responseError));
            }
        }

        private async Task WriteErrorLog(HttpContext context, Exception ex)
        {
            string logFilePath;
            string errorLogFileName;
            StringBuilder sbErrorLog = new StringBuilder();

            try
            {
                if (!_appSettings.EnableWriteLog)
                    return;

                logFilePath = $"{Directory.GetCurrentDirectory()}\\ErrorLogs\\";
                errorLogFileName = $"{logFilePath}ErrorLog_{DateTime.Now.ToString("yyyyMMddHHmmss")}.txt";

                if (!Directory.Exists(logFilePath))
                {
                    Directory.CreateDirectory(logFilePath);
                }

                if (!File.Exists(errorLogFileName))
                {
                    await File.Create(errorLogFileName).DisposeAsync();
                }

                sbErrorLog.Append(DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                sbErrorLog.Append(Environment.NewLine);
                sbErrorLog.Append("Error Message:");
                sbErrorLog.Append(Environment.NewLine);
                sbErrorLog.Append(ex.Message);
                sbErrorLog.Append(Environment.NewLine);
                sbErrorLog.Append("Full Exception Details:");
                sbErrorLog.Append(Environment.NewLine);
                
                sbErrorLog.Append(ex.ExceptionJson());
                sbErrorLog.Append(Environment.NewLine);
                sbErrorLog.Append(Environment.NewLine);
                sbErrorLog.Append("*************************************************************************");
                sbErrorLog.Append(Environment.NewLine);
                sbErrorLog.Append(Environment.NewLine);

                await File.AppendAllTextAsync(errorLogFileName, sbErrorLog.ToString());
            }
            catch (Exception exception)
            {
                _responseError.IsSuccess = false;
                _responseError.Message = "Error occurred while writing Error log file";
                _responseError.Data = exception;

                await context.Response.WriteAsync(JsonSerializer.Serialize(_responseError));
            }
        }
    }
}
