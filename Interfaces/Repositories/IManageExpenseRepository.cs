using Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Interfaces.Repositories
{
    public interface IManageExpenseRepository
    {
        #region Expense

        Task<int> SaveExpense(Expense_Request parameters);

        Task<IEnumerable<Expense_Response>> GetExpenseList(Expense_Search parameters);

        Task<Expense_Response?> GetExpenseById(int Id);

        #endregion

        #region Expense Details

        Task<int> SaveExpenseDetails(ExpenseDetails_Request parameters);

        Task<IEnumerable<ExpenseDetails_Response>> GetExpenseDetailsList(ExpenseDetails_Search parameters);

        Task<ExpenseDetails_Response?> GetExpenseDetailsById(int Id);

        Task<int> ExpenseDetailsApproveNReject(Expense_ApproveNReject parameters);

        Task<IEnumerable<ExpenseDetailsApproveRejectHistory_Response>> GetExpenseDetailsApproveRejectHistoryList(ExpenseDetailsApproveRejectHistory_Search parameters);

        #endregion
    }
}
