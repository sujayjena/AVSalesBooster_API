using Dapper;
using Helpers;
using Interfaces.Repositories;
using Microsoft.Extensions.Configuration;
using Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repositories
{
    public class ManageExpenseRepository : BaseRepository, IManageExpenseRepository
    {
        private IConfiguration _configuration;

        public ManageExpenseRepository(IConfiguration configuration) : base(configuration)
        {
            _configuration = configuration;
        }

        #region Expense

        public async Task<int> SaveExpense(Expense_Request parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@Id", parameters.Id);
            queryParameters.Add("@ExpenseNumber", parameters.ExpenseNumber);
            queryParameters.Add("@WithoutVisit", parameters.WithoutVisit);
            queryParameters.Add("@VisitId", parameters.VisitId);
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@UserId", SessionManager.LoggedInUserId);

            return await SaveByStoredProcedure<int>("SaveExpense", queryParameters);
        }

        public async Task<IEnumerable<Expense_Response>> GetExpenseList(Expense_Search parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@EmployeeId", parameters.EmployeeId);
            queryParameters.Add("@FilterType", parameters.FilterType);
            queryParameters.Add("@ValueForSearch", parameters.ValueForSearch.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@UserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<Expense_Response>("GetExpenseList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }

        public async Task<Expense_Response?> GetExpenseById(int Id)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@Id", Id);

            return (await ListByStoredProcedure<Expense_Response>("GetExpenseById", queryParameters)).FirstOrDefault();
        }

        #endregion

        #region Expense Details

        public async Task<int> SaveExpenseDetails(ExpenseDetails_Request parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@Id", parameters.Id);
            queryParameters.Add("@ExpenseId", parameters.ExpenseId);
            queryParameters.Add("@ExpenseDate", parameters.ExpenseDate);
            queryParameters.Add("@ExpenseTypeId", parameters.ExpenseTypeId);
            queryParameters.Add("@ExpenseDescription", parameters.ExpenseDescription);
            queryParameters.Add("@ExpenseAmount", parameters.ExpenseAmount);
            queryParameters.Add("@ExpenseImageFileName", parameters.ExpenseImageFileName);
            queryParameters.Add("@ExpenseImageOriginalFileName", parameters.ExpenseImageOriginalFileName);
            queryParameters.Add("@StatusId", parameters.StatusId);
            queryParameters.Add("@UserId", SessionManager.LoggedInUserId);

            return await SaveByStoredProcedure<int>("SaveExpenseDetails", queryParameters);
        }

        public async Task<IEnumerable<ExpenseDetails_Response>> GetExpenseDetailsList(ExpenseDetails_Search parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@ExpenseId", parameters.ExpenseId);
            queryParameters.Add("@StatusId", parameters.StatusId);
            queryParameters.Add("@ValueForSearch", parameters.ValueForSearch.SanitizeValue());
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@UserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<ExpenseDetails_Response>("GetExpenseDetailsList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }

        public async Task<ExpenseDetails_Response?> GetExpenseDetailsById(int Id)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@Id", Id);

            return (await ListByStoredProcedure<ExpenseDetails_Response>("GetExpenseDetailsById", queryParameters)).FirstOrDefault();
        }

        public async Task<int> ExpenseDetailsApproveNReject(Expense_ApproveNReject parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@Id", parameters.Id);
            queryParameters.Add("@ExpenseId", parameters.ExpenseId);
            queryParameters.Add("@StatusId", parameters.StatusId);
            queryParameters.Add("@Remarks", parameters.Remarks);
            queryParameters.Add("@UserId", SessionManager.LoggedInUserId);

            return await SaveByStoredProcedure<int>("ExpenseDetailsApproveNReject", queryParameters);
        }

        public async Task<IEnumerable<ExpenseDetailsApproveRejectHistory_Response>> GetExpenseDetailsApproveRejectHistoryList(ExpenseDetailsApproveRejectHistory_Search parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@ExpenseDetailsId", parameters.ExpenseDetailsId);
            queryParameters.Add("@ValueForSearch", parameters.ValueForSearch.SanitizeValue());
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@UserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<ExpenseDetailsApproveRejectHistory_Response>("GetExpenseDetailsApproveRejectHistoryList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }

        #endregion
    }
}
