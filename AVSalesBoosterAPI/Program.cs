using AVSalesBoosterAPI.CustomAttributes;
using AVSalesBoosterAPI.Middlewares;
using Helpers;
using Interfaces.Repositories;
using Interfaces.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.FileProviders;
using Microsoft.OpenApi.Models;
using Models;
using Repositories;
using Services;

var builder = WebApplication.CreateBuilder(args);
var services = builder.Services;

//Services related configurations
{
    services.AddControllers();
    services.AddHttpContextAccessor();
    services.AddSignalR();

    services.AddSwaggerGen(options =>
    {
        options.SwaggerDoc("v1", new OpenApiInfo
        {
            Title = "AV Sales Booster API",
            Version = "v1",
        });

        options.OperationFilter<SwaggerCustomFilter>();
        options.SchemaFilter<SwaggerFormDataSchemaFilter>();

        options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
        {
            Description = "JWT Authorization header using the Bearer scheme.",
            Type = SecuritySchemeType.Http,
            Scheme = "bearer"
        });

        options.AddSecurityRequirement(new OpenApiSecurityRequirement
        {
            {
                new OpenApiSecurityScheme
                {
                    Reference = new OpenApiReference
                    {
                        Type = ReferenceType.SecurityScheme,
                        Id = "Bearer"
                    }
                },
                Array.Empty<string>()
            }
        });
    });

    services.Configure<AppSettings>(builder.Configuration.GetSection("AppSettings"));

    services.AddSingleton<IFileManager, FileManager>();
    //services.AddSingleton<IMessageHubClient, MessageHubClient>();

    services.AddScoped<IJwtUtilsService, JwtUtilsService>();
    services.AddScoped<IProfileService, ProfileService>();
    services.AddScoped<IProfileRepository, ProfileRepository>();
    services.AddScoped<IAdminService, AdminService>();
    services.AddScoped<IAdminRepository, AdminRepository>();
    services.AddScoped<IManageTerritoryService, ManageTerritoryService>();
    services.AddScoped<IManageTerritoryRepository, ManageTerritoryRepository>();
    services.AddScoped<IManageDesignService, ManageDesignService>();
    services.AddScoped<IManageDesignRepository, ManageDesignRepository>();
    services.AddScoped<IReferenceService, ReferenceService>();
    services.AddScoped<IReferenceRepository, ReferenceRepository>();
    services.AddScoped<ILeaveService, LeaveService>();
    services.AddScoped<ILeaveRepository, LeaveRepository>();
    services.AddScoped<ICustomerService, CustomerService>();
    services.AddScoped<ICustomerRepository, CustomerRepository>();
    services.AddScoped<IVisitService, VisitService>();
    services.AddScoped<IVisitRepository, VisitRepository>();
    services.AddScoped<IDashboardService, DashboardService>();
    services.AddScoped<IDashboardRepository, DashboardRepository>();
    services.AddScoped<INotificationService, NotificationService>();
    services.AddScoped<INotificationRepository, NotificationRepository>();
    services.AddScoped<IBroadCastService, BroadCastService>();
    services.AddScoped<IBroadCastRepository, BroadCastRepository>();
    services.AddScoped<IIndustryService, IndustryService>();
    services.AddScoped<IIndustryRepository, IndustryRepository>();
    services.AddScoped<IServiceDetailsService, ServiceDetailsService>();
    services.AddScoped<IServiceDetailsRepository, ServiceDetailsRepository>();
    services.AddScoped<IManageExpenseService, ManageExpenseService>();
    services.AddScoped<IManageExpenseRepository, ManageExpenseRepository>();
    services.AddScoped<IManageActivitiesService, ManageActivitiesService>();
    services.AddScoped<IManageActivitiesRepository, ManageActivitiesRepository>();

    services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer();

    //To validate parameters (Model State)
    services.Configure<ApiBehaviorOptions>(options =>
    {
        options.InvalidModelStateResponseFactory = (actionContext) =>
        {
            ResponseModel response = ModelStateHelper.GetValidationErrorsList(actionContext);
            return new BadRequestObjectResult(response);
        };
    });

    services.Configure<FormOptions>(x =>
    {
        x.ValueLengthLimit = int.MaxValue;
        x.MultipartBodyLengthLimit = int.MaxValue; // In case of multipart
    });
}

var app = builder.Build();

//Web Application related configurations
{
    app.UseMiddleware<ExceptionMiddleware>();
    app.UseMiddleware<JwtMiddleware>();

    //Global CORS policy - To disable CORS error
    app.UseCors(cors => cors
        .AllowAnyOrigin()
        .AllowAnyMethod()
        .AllowAnyHeader());

    //app.UseHttpsRedirection();
    app.UseRouting();

    #region Swagger Configurations
    //if (app.Environment.IsDevelopment())
    //{
    app.UseSwagger();
    app.UseSwaggerUI(s =>
    {
        s.SwaggerEndpoint("/swagger/v1/swagger.json", "AVSalesBoosterAPI");
        //s.RoutePrefix = string.Empty;
    });
    //}
    #endregion

    //app.UseStaticFiles();
    app.UseStaticFiles(new StaticFileOptions()
    {
        FileProvider = new PhysicalFileProvider(Path.Combine(Directory.GetCurrentDirectory(), @"Uploads")),
        RequestPath = new PathString("/Uploads")


        //FileProvider = new PhysicalFileProvider(Path.Combine(builder.Environment.ContentRootPath, "Uploads")),
        //RequestPath = new PathString("/Uploads")
    });

    app.UseAuthentication();
    app.UseAuthorization();

    app.MapControllers();
    app.MapHub<MessageHubClient>("/notification");
}

app.Run();
