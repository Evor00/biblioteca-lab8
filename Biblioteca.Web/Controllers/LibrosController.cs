using Biblioteca.Web.Models;
using Biblioteca.Web.Repositorios;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;

namespace Biblioteca.Web.Controllers;

public class LibrosController : Controller
{
    private readonly LibroRepositorio _libros;

    public LibrosController(LibroRepositorio libros)
    {
        _libros = libros;
    }

    public async Task<IActionResult> Index(string? titulo)
    {
        ViewData["Titulo"] = titulo;
        var libros = string.IsNullOrWhiteSpace(titulo)
            ? await _libros.ListarActivosAsync()
            : await _libros.BuscarPorTituloAsync(titulo.Trim());
        return View(libros);
    }

    public async Task<IActionResult> Details(int? id)
    {
        if (id is null)
            return NotFound();

        var libro = await _libros.ObtenerPorIdAsync(id.Value);
        if (libro is null)
            return NotFound();

        return View(libro);
    }

    public async Task<IActionResult> Create()
    {
        await CargarAutoresAsync();
        return View(new Libro());
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(Libro libro)
    {
        if (!ModelState.IsValid)
        {
            await CargarAutoresAsync(libro.AutorId);
            return View(libro);
        }

        var registrado = await _libros.InsertarAsync(libro);
        if (!registrado)
        {
            ModelState.AddModelError(nameof(libro.ISBN), "Ya existe un libro con ese ISBN.");
            await CargarAutoresAsync(libro.AutorId);
            return View(libro);
        }

        TempData["Mensaje"] = "El libro se registró correctamente.";
        return RedirectToAction(nameof(Index));
    }

    public async Task<IActionResult> Edit(int? id)
    {
        if (id is null)
            return NotFound();

        var libro = await _libros.ObtenerPorIdAsync(id.Value);
        if (libro is null || !libro.Activo)
            return NotFound();

        await CargarAutoresAsync(libro.AutorId);
        return View(libro);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, Libro libro)
    {
        if (id != libro.LibroId)
            return NotFound();

        if (!ModelState.IsValid)
        {
            await CargarAutoresAsync(libro.AutorId);
            return View(libro);
        }

        var actualizado = await _libros.ActualizarAsync(libro);
        if (!actualizado)
        {
            ModelState.AddModelError(nameof(libro.ISBN), "No se pudo actualizar el libro. Revise que el ISBN no esté repetido.");
            await CargarAutoresAsync(libro.AutorId);
            return View(libro);
        }

        TempData["Mensaje"] = "El libro se actualizó correctamente.";
        return RedirectToAction(nameof(Index));
    }

    public async Task<IActionResult> Delete(int? id)
    {
        if (id is null)
            return NotFound();

        var libro = await _libros.ObtenerPorIdAsync(id.Value);
        if (libro is null || !libro.Activo)
            return NotFound();

        return View(libro);
    }

    [HttpPost, ActionName("Delete")]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> DeleteConfirmed(int id)
    {
        var eliminado = await _libros.EliminarAsync(id);
        TempData["Mensaje"] = eliminado
            ? "El libro se dio de baja correctamente."
            : "No se pudo dar de baja el libro.";
        return RedirectToAction(nameof(Index));
    }

    private async Task CargarAutoresAsync(int? autorId = null)
    {
        var autores = await _libros.ListarAutoresActivosAsync();
        ViewData["Autores"] = new SelectList(autores, "AutorId", "Nombre", autorId);
    }
}
