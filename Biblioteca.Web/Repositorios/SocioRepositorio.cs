using System.Data;
using Biblioteca.Web.Models;
using Dapper;
using Microsoft.Data.SqlClient;

namespace Biblioteca.Web.Repositorios;

public class SocioRepositorio
{
    private readonly string _connectionString;

    public SocioRepositorio(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("BibliotecaDB")
            ?? throw new InvalidOperationException("No se encontró la cadena de conexión 'BibliotecaDB'.");
    }

    public async Task<IEnumerable<Socio>> ListarActivosAsync()
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.QueryAsync<Socio>(
            "sp_Socio_ListarActivos",
            commandType: CommandType.StoredProcedure);
    }

    public async Task<bool> InsertarAsync(Socio socio)
    {
        using var connection = new SqlConnection(_connectionString);
        var filas = await connection.ExecuteAsync(
            "sp_Socio_Insertar",
            new { socio.DNI, socio.Nombre, socio.Email },
            commandType: CommandType.StoredProcedure);
        return filas > 0;
    }

    public async Task<IEnumerable<PrestamoReporte>> ReportePorFechasAsync(DateTime? desde, DateTime? hasta)
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.QueryAsync<PrestamoReporte>(
            "sp_Prestamo_Reporte",
            new { Desde = desde, Hasta = hasta },
            commandType: CommandType.StoredProcedure);
    }
}
