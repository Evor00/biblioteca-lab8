using Biblioteca.Web.Models;
using Biblioteca.Web.Repositorios;
using Microsoft.AspNetCore.Mvc;

namespace Biblioteca.Web.Controllers;

public class SociosController : Controller
{
    private readonly SocioRepositorio _socios;

    public SociosController(SocioRepositorio socios)
    {
        _socios = socios;
    }

    public async Task<IActionResult> Index()
    {
        var socios = await _socios.ListarActivosAsync();
        return View(socios);
    }

    public IActionResult Create()
    {
        return View(new Socio());
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(Socio socio)
    {
        if (!ModelState.IsValid)
            return View(socio);

        var registrado = await _socios.InsertarAsync(socio);
        if (!registrado)
        {
            ModelState.AddModelError(nameof(socio.DNI), "Ya existe un socio con ese DNI.");
            return View(socio);
        }

        TempData["Mensaje"] = "El socio se registró correctamente.";
        return RedirectToAction(nameof(Index));
    }
}
