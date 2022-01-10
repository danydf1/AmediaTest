use Peliculas
GO

--Tablas VENTA/ALQUILER


create table tPeliculaAlquilada
(cod_alquiler INT PRIMARY KEY IDENTITY ,
cod_usuario INT not null foreign key references tUSers(cod_usuario),
cod_pelicula INT not null foreign key references tPelicula(cod_pelicula),
precio_alquiler NUMERIC(18,2),
fecha_alquiler Date,
cantidad int,
Estado int foreign key references tDevuelto(cod_Devuelto)
)
GO
create table tPeliculaVendida
(cod_venta INT PRIMARY KEY IDENTITY,
cod_usuario INT not null foreign key references tUSers(cod_usuario),
cod_pelicula INT not null foreign key references tPelicula(cod_pelicula),
precio_venta NUMERIC(18,2),
fecha_venta Date,
cantidad int
)

GO
create table tDevuelto
(
cod_Devuelto INT PRIMARY KEY IDENTITY,
txt_desc varchar (50)
)
GO
insert into tDevuelto (txt_desc) values ('Devuelto')
insert into tDevuelto (txt_desc) values ('Sin devolver')
GO
--1 AGREGAR USUARIO
CREATE PROCEDURE Agregar_User(
@User VARCHAR(50),
@Pass VARCHAR(50),
@Nombre VARCHAR(50),
@Apellido VARCHAR(50),
@NroDoc INT,
@codRol INT,
@Activo INT
)
AS
BEGIN
IF Exists (SELECT * FROM tUsers WHERE @NroDoc = nro_doc)

  RAISERROR('Usuario ya registrado con ese DNI', 16, 1)
   ELSE
 BEGIN
	INSERT INTO tUsers(txt_user,txt_password,txt_nombre,txt_apellido,nro_doc,cod_rol,sn_activo)  
	VALUES  (@User,@Pass,@Nombre, @Apellido,  @NroDoc, @codRol , @Activo)  
  END
END
  GO
--2 ABM DE PELICULA
CREATE PROCEDURE PeliculaInsertarModificarBorrar (
@id INT,
@Titulo VARCHAR(50),
@DisponiblesAlquiler INT,
@DisponiblesVenta INT,
@precioVenta NUMERIC(18,2),
@precioAquiler NUMERIC(18,2),
@Accion VARCHAR(20) = '')
AS
BEGIN
IF Exists (SELECT * FROM tPelicula WHERE @Titulo like '%'+txt_desc+'%')

  RAISERROR('ya esta disponible el genero', 16, 1)
   ELSE
  BEGIN
      IF @Accion= 'Insertar'
        BEGIN
         INSERT INTO tPelicula(txt_desc,cant_disponibles_alquiler,cant_disponibles_venta,precio_alquiler,precio_venta)
            VALUES (@Titulo,@DisponiblesAlquiler,@DisponiblesVenta,@precioAquiler,@precioVenta)
	  END
	  
	 ELSE IF @Accion = 'Modificar'
        BEGIN
            UPDATE tPelicula
            SET    txt_desc = @Titulo,
                   cant_disponibles_alquiler = @DisponiblesAlquiler,
                   cant_disponibles_venta = @DisponiblesVenta,
				   precio_alquiler = @precioAquiler,	
				   precio_venta = @precioVenta
            WHERE  cod_pelicula = @id
        END
      ELSE IF @Accion = 'Borrar'
        BEGIN
            UPDATE tPelicula
            SET
				cant_disponibles_alquiler = 0,
                cant_disponibles_venta = 0
				   
            WHERE  cod_pelicula = @id
        END
	END
END
GO
--3 CREAR GENERO
Create Procedure Crear_genero(
@Genero varchar(100)
)
AS
BEGIN
IF Exists (SELECT * FROM tGenero WHERE @Genero like '%'+txt_desc+'%')

  RAISERROR('ya esta disponible el genero', 16, 1)
   ELSE
 BEGIN
	INSERT INTO tGenero(txt_desc)  
	VALUES (@Genero)  
  END

END
GO
--4 AGREGAR GENERO A PELICULA
Create Procedure Agregar_Genero(
@codPelicula int,
@codGenero int
)
AS
BEGIN
IF Exists (SELECT * FROM tGeneroPelicula WHERE @codGenero = cod_genero and @codPelicula = cod_pelicula)

  RAISERROR('esta pelicula tiene ese genero', 16, 1)
   ELSE
 BEGIN
	INSERT INTO tGeneroPelicula(cod_pelicula,cod_genero)  
	VALUES (@codPelicula,@codGenero)  
  END

END

GO

--5 ALQUILER Y VENTA

CREATE PROCEDURE alquilerVenderPelicula(
@CodUsuario  int,
@CodPelicula int,
@precio NUMERIC(18,2),
@Cant int,
@Accion VARCHAR(20) = '')
AS
BEGIN
IF Exists (SELECT * FROM tPelicula WHERE @CodPelicula = cod_pelicula)
 BEGIN
      IF @Accion= 'Alquilar'
	  BEGIN
		IF Exists (Select * from tPelicula where cant_disponibles_alquiler <> 0)
        BEGIN
         INSERT INTO tPeliculaAlquilada(
		 cod_usuario,
		 cod_pelicula,
		 precio_alquiler,
		 fecha_alquiler, 
		 cantidad,
		 Estado
		 )
            VALUES (@CodUsuario,
			@CodPelicula,
			@precio,
			getdate(),
			@Cant,
			2
			)	
		 END
		  ELSE
		  RAISERROR('NO HAY DISPONIBLES', 16, 1)
	  END
	 ELSE IF @Accion = 'Vender'
        BEGIN
		IF Exists (Select * from tPelicula where @CodPelicula = cod_pelicula and cant_disponibles_venta <> 0)
        BEGIN
         INSERT INTO tPeliculaVendida(
		 cod_usuario,
		 cod_pelicula,
		 precio_venta,
		 fecha_venta, 
		 cantidad
		 )
            VALUES (@CodUsuario,
			@CodPelicula,
			@precio,
			getdate(),
			@Cant
			)	
		 END
		  ELSE
		  RAISERROR('NO HAY DISPONIBLES', 16, 1)
	  END
	END

   ELSE
   RAISERROR('Pelicula no disponible', 16, 1)
END
GO

--6 Peliculas en Stock para alquilar

CREATE PROCEDURE PeliculasAlquierStock
AS
BEGIN
	Select txt_desc as Titulo, cant_disponibles_alquiler as Stock, precio_alquiler from tPelicula where cant_disponibles_alquiler <> 0
END

GO

--7 Peliculas en Stock para alquilar

CREATE PROCEDURE PeliculasVentaStock
AS
BEGIN
	Select txt_desc as Titulo, cant_disponibles_venta as Stock, precio_venta from tPelicula where cant_disponibles_venta <> 0
END
GO
--8 Alquilar PElicula

CREATE PROCEDURE alquilarPelicula(
@CodUsuario  int,
@CodPelicula int,
@precio NUMERIC(18,2)
)
AS
BEGIN
IF Exists (Select * from tPelicula where cant_disponibles_alquiler <> 0)
        BEGIN
         INSERT INTO tPeliculaAlquilada(
		 cod_usuario,
		 cod_pelicula,
		 precio_alquiler,
		 fecha_alquiler, 
		 cantidad,
		 Estado
		 )
            VALUES (@CodUsuario,
			@CodPelicula,
			@precio,
			getdate(),
			1,
			2
			)	
		 END
		  ELSE
		  RAISERROR('NO HAY DISPONIBLES', 16, 1)
END

GO

--9 Vender Pelicula

CREATE PROCEDURE VentaPelicula(
@CodUsuario  int,
@CodPelicula int,
@precio NUMERIC(18,2)
)
AS

BEGIN
		IF Exists (Select * from tPelicula where @CodPelicula = cod_pelicula and cant_disponibles_venta <> 0)
        BEGIN
         INSERT INTO tPeliculaVendida(
		 cod_usuario,
		 cod_pelicula,
		 precio_venta,
		 fecha_venta
		 )
            VALUES (@CodUsuario,
			@CodPelicula,
			@precio,
			getdate(),
			1
			)	
		 END
		  ELSE
		  RAISERROR('NO HAY DISPONIBLES', 16, 1)
END

GO
--10 Devolver película

create procedure devolverPelicula(
@cod_usuario int,
@cod_pelicula int
)
AS
BEGIN
IF Exists( Select * from tPeliculaAlquilada where @cod_usuario = cod_usuario)
UPDATE tPeliculaAlquilada
            SET    
			  Estado = 1
            WHERE  cod_pelicula = @cod_pelicula and cod_usuario = @cod_usuario
	Else
	RAISERROR('NO SE ENCUENTRA EL USUARIO', 16, 1)
END
GO

--11 Ver películas que no fueron devueltas y que usuarios la tienen

CREATE PROCEDURE SinDevolver
AS
BEGIN
	Select P.txt_desc, U.txt_apellido + ' ' + U.txt_nombre , D.txt_desc   from tPeliculaAlquilada as PA
	inner join tPelicula as P ON P.cod_pelicula = PA.cod_pelicula
	inner join tDevuelto as D on D.cod_Devuelto = PA.Estado
	inner join tUsers as U on U.cod_usuario = PA.cod_usuario
	where D.cod_Devuelto = 2
END
GO

--12 Ver qué películas fueron alquiladas por usuario y cuánto pagó y que día

CREATE PROCEDURE AlquilaresPorUsuario
AS
BEGIN
	Select P.txt_desc as Titulo , U.txt_apellido + ' ' + U.txt_nombre as Usuario , SUM(p.precio_alquiler * pa.cantidad) as Total, pa.fecha_alquiler as Fecha, D.txt_desc as Estado 
	from tPeliculaAlquilada as PA
	inner join tPelicula as P ON P.cod_pelicula = PA.cod_pelicula
	inner join tDevuelto as D on D.cod_Devuelto = PA.Estado
	inner join tUsers as U on U.cod_usuario = PA.cod_usuario

		Group by P.txt_desc, txt_apellido,txt_nombre,pa.fecha_alquiler,D.txt_desc
END
GO

GO
--13 Ver todas las películas, cuantas veces fueron alquiladas y cuanto se recaudo por ellas
CREATE PROCEDURE AlquilaresPorPeliculas
AS
BEGIN
	Select P.txt_desc as Titulo , Count(pa.cod_pelicula) as Cantidad ,sum(pa.precio_alquiler) as Total
	from tPelicula as P
	inner join tPeliculaAlquilada as PA ON P.cod_pelicula = PA.cod_pelicula

	Group by P.txt_desc
END
GO
