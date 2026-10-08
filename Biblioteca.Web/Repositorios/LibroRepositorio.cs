using System.Data;
using Biblioteca.Web.Models;
using Dapper;
using Microsoft.Data.SqlClient;

namespace Biblioteca.Web.Repositorios;

public class LibroRepositorio
{
    private readonly string _connectionString;

    public LibroRepositorio(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("BibliotecaDB")
            ?? throw new InvalidOperationException("No se encontró la cadena de conexión 'BibliotecaDB'.");
    }

    public async Task<IEnumerable<Libro>> ListarActivosAsync()
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.QueryAsync<Libro>(
            "sp_Libro_ListarActivos",
            commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<Libro>> BuscarPorTituloAsync(string titulo)
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.QueryAsync<Libro>(
            "sp_Libro_BuscarPorTitulo",
            new { Titulo = titulo },
            commandType: CommandType.StoredProcedure);
    }

    public async Task<Libro?> ObtenerPorIdAsync(int libroId)
    {
        using var connection = new SqlConnection(_connectionString);
        var libros = await connection.QueryAsync<Libro>(
            "sp_Libro_ObtenerPorId",
            new { LibroId = libroId },
            commandType: CommandType.StoredProcedure);
        return libros.FirstOrDefault();
    }

    public async Task<bool> InsertarAsync(Libro libro)
    {
        using var connection = new SqlConnection(_connectionString);
        var filas = await connection.ExecuteAsync(
            "sp_Libro_Insertar",
            new
            {
                libro.Titulo,
                libro.ISBN,
                libro.AutorId,
                libro.Ejemplares
            },
            commandType: CommandType.StoredProcedure);
        return filas > 0;
    }

    public async Task<bool> ActualizarAsync(Libro libro)
    {
        using var connection = new SqlConnection(_connectionString);
        var filas = await connection.ExecuteAsync(
            "sp_Libro_Actualizar",
            new
            {
                libro.LibroId,
                libro.Titulo,
                libro.ISBN,
                libro.AutorId,
                libro.Ejemplares
            },
            commandType: CommandType.StoredProcedure);
        return filas > 0;
    }

    public async Task<bool> EliminarAsync(int libroId)
    {
        using var connection = new SqlConnection(_connectionString);
        var filas = await connection.ExecuteAsync(
            "sp_Libro_Eliminar",
            new { LibroId = libroId },
            commandType: CommandType.StoredProcedure);
        return filas > 0;
    }

    public async Task<IEnumerable<Autor>> ListarAutoresActivosAsync()
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.QueryAsync<Autor>(
            "sp_Autor_ListarActivos",
            commandType: CommandType.StoredProcedure);
    }
}
