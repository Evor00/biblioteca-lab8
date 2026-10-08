using Biblioteca.Web.Repositorios;
using Microsoft.AspNetCore.Mvc;

namespace Biblioteca.Web.Controllers;

public class PrestamosController : Controller
{
    private readonly SocioRepositorio _socios;

    public PrestamosController(SocioRepositorio socios)
    {
        _socios = socios;
    }

    public async Task<IActionResult> Reporte(DateTime? desde, DateTime? hasta)
    {
        ViewData["Desde"] = desde?.ToString("yyyy-MM-dd");
        ViewData["Hasta"] = hasta?.ToString("yyyy-MM-dd");

        if (desde.HasValue && hasta.HasValue && desde.Value.Date > hasta.Value.Date)
        {
            ViewData["Error"] = "La fecha inicial no puede ser posterior a la fecha final.";
            return View(Array.Empty<Models.PrestamoReporte>());
        }

        var prestamos = await _socios.ReportePorFechasAsync(desde?.Date, hasta?.Date);
        return View(prestamos);
    }
}
