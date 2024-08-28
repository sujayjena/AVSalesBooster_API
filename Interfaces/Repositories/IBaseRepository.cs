using Microsoft.Extensions.Configuration;

namespace Interfaces.Repositories
{
    public interface IBaseRepository
    {
        IConfigurationSection GetConfigurationSection(string Key);

        //Task<T> SaveByStoredProcedure<T>(string storedProcedureName);
        //Task<T> SaveByStoredProcedure<T>(string storedProcedureName, object parameters);
        //Task<IEnumerable<T>> ListByStoredProcedure<T>(string storedProcedureName);
        //Task<IEnumerable<T>> ListByStoredProcedure<T>(string storedProcedureName, object parameters);
        //Task<IEnumerable<T>> ListByQuery<T>(string query);
        //Task<IEnumerable<T>> ListByQuery<T>(string query, object parameters);
        //Task<int> ExecuteNonQuery(string procedureName);
        //Task<int> ExecuteNonQuery(string procedureName, object parameters);
    }
}
