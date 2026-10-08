using System.ComponentModel.DataAnnotations;

namespace Biblioteca.Web.Models;

public class PrestamoReporte
{
    [Display(Name = "Socio")]
    public string Socio { get; set; } = string.Empty;

    [Display(Name = "Libros")]
    public string Libros { get; set; } = string.Empty;

    [Display(Name = "Fecha límite")]
    [DataType(DataType.Date)]
    public DateTime FechaLimite { get; set; }

    [Display(Name = "Estado")]
    public string Estado { get; set; } = string.Empty;
}
