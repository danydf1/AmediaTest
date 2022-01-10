using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TestDanielFernandez.data;
using TestDanielFernandez.Models;

namespace TestDanielFernandez.Controllers
{
    public class UsuariosController : Controller
    {
        private readonly ApplicationDbContext _context;

        public UsuariosController(ApplicationDbContext context)
        {
            _context = context;
        }

        //HTTP Get Index
        public IActionResult Index()
        {
            IEnumerable<Usuario> listUsuarios = _context.Usuario;
            return View(listUsuarios);
        }

        //HTTP Get Create
        public IActionResult Login(string email)
        {
            if (email == null || email == "")
            {
                return NotFound();
            }

            var usuario = _context.Usuario.Find(email);
            if (usuario == null)
            {
                return NotFound();
            }

            return View(usuario);
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        //HTTP post Create
        public IActionResult Login(Usuario usuario)
        {
            IEnumerable<Usuario> listUsuarios = _context.Usuario;

            foreach (var item in listUsuarios)
            {
                if (item.Mail == usuario.Mail && item.Password == usuario.Password)
                {
                    return View("Bienvenido");
                }
            }
            return NotFound();
        }
        //HTTP Get Create
        public IActionResult Create()
        {
            return View();
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        //HTTP post Create
        public IActionResult Create(Usuario usuario)
        {
            if (ModelState.IsValid)
            {
                _context.Usuario.Add(usuario);
                _context.SaveChanges();

                TempData["mensaje"] = "Registrado correctamente";

                return RedirectToAction("Index");
            }
            return View();
        }

        public IActionResult Edit(int? id)
        {
            if(id == null || id == 0)
            {
                return NotFound();
            }

            var usuario = _context.Usuario.Find(id);
            if(usuario == null)
            {
                return NotFound();
            }

            return View(usuario);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        //HTTP post Create
        public IActionResult Edit(Usuario usuario)
        {
            if (ModelState.IsValid)
            {
                _context.Usuario.Update(usuario);
                _context.SaveChanges();

                TempData["mensaje"] = "Se actualizo correctamente";

                return RedirectToAction("Index");
            }
            return View();
        }

        public IActionResult Delete(int? id)
        {
            if (id == null || id == 0)
            {
                return NotFound();
            }

            var usuario = _context.Usuario.Find(id);
            if (usuario == null)
            {
                return NotFound();
            }

            return View(usuario);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        //HTTP post Create
        public IActionResult DeleteUsuario(int? id)
        {
            var Usuario = _context.Usuario.Find(id);

            if (Usuario == null)
            {
                return NotFound();
             }
            _context.Usuario.Remove(Usuario);
            _context.SaveChanges();

            TempData["mensaje"] = "Se elimino correctamente";

            return RedirectToAction("Index");
        }
    }
}
