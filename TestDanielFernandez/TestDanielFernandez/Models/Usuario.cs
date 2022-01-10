using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace TestDanielFernandez.Models
{
    public class Usuario
    {
        [Key]
        public int ID { get; set; }

        [Required(ErrorMessage ="Ingrese un email valido")]
        [MinLength(4, ErrorMessage = "Ingrese un email valido")]
        public string Mail { get; set; }

        [Required(ErrorMessage = "Coloque su contraseña")]
        [MinLength(4, ErrorMessage = "Contaseña invalida")]
        public string Password { get; set; }

        [Required(ErrorMessage = "Ingrese su nombre")]
        [MinLength(1, ErrorMessage = "Ingrese su nombre")]
        public string Nombre { get; set; }

        [Required(ErrorMessage = "Ingrese su apellido")]
        [MinLength(1, ErrorMessage = "Ingrese su apellido")]
        public string Apellido { get; set; }

        [Required(ErrorMessage = "Ingrese su DNI")]
        public int Dni { get; set; }

        public String Rol { get; set; }
        public int Activo { get; set; }

    }
}
