--1. Crear un procedimiento almacenado (uno para cada uno) para cargar datos los conceptos de alumnos, 
--materias, cursos, profesores, cuatrimestres e intereses por mora (este solo carga un registro 
--para cada año de la carrera, si el año existe se actualiza.)
CREATE PROCEDURE cargaAlumnos
@id int,
@nombre varchar(50),
@apellido varchar(50),
@email varchar(50)

as
begin
	insert into ESTUDIANTES (id_estudiante,nombre,apellido,email)
	values (@id,@nombre,@apellido,@email);
end;
go;
exec cargaAlumnos 
	@id = 700,
	@nombre = 'Ignacio',
	@apellido = 'Gutierrez',
	@email = 'Ignacio@example.com';

CREATE PROCEDURE cargaMateria
@id int,
@nombre_materia varchar(50),
@creditos int,
@costo_mensual decimal(6,2)

as 
begin
	insert into MATERIAS (id_materia,nombre_materia,creditos,costo_curso_mensual)
	values(@id,@nombre_materia,@creditos,@costo_mensual);
end
go;

CREATE PROCEDURE cargaCurso
@id int,
@nombre varchar(100),
@descripcion varchar(100),
@anio int,
@id_prof int,
@id_materia int
AS
BEGIN
    INSERT INTO CURSOS (id_curso, nombre_curso, descripcion, anio, id_profesor, id_materia)
    VALUES (@id, @nombre, @descripcion, @anio, @id_prof, @id_materia);
END;
go;

CREATE PROCEDURE cargaProfesor
@id int,
@nombre varchar(30),
@apellido varchar(30),
@especialidad varchar(60)
as 
begin
	insert into PROFESORES(id_profesor,nombre,apellido,especialidad)
	values(@id,@nombre,@apellido,@especialidad);
end
go;

CREATE PROCEDURE cargaCuatrimestre
@id int,
@nombre varchar(100),
@inicio date,
@fin date
as 
begin
	insert into CUATRIMESTRE(id_cuatrimestre,nombre,fecha_inicio,fecha_fin)
	values(@id,@nombre,@inicio,@fin);
end
go;

CREATE PROCEDURE cargaInteresPorMora
@anio int,
@porcentaje decimal(5,2)
AS
BEGIN
IF EXISTS(Select* from INTERESPORMORA where @anio = anio_carrera)
	BEGIN
		UPDATE INTERESPORMORA
		set porcentaje_interes = @porcentaje
		where anio = @anio_carrera;
	END
	ELSE 
	BEGIN
		insert into INTERESPORMORA(anio_carrera,porcentaje_interes)
		values (@anio,@porcentaje)
	END
END
go;

--2.Crear un procedimiento que permita dar de baja a un alumno. 
--El mismo debe contemplar que la cuenta corriente este en cero 
--para hacerlo. No debe borrarse el historial del alumno, 
--solo indicar que esta de baja.
CREATE PROCEDURE darBaja
@ID_ESTUDIANTE int

AS
BEGIN
	DECLARE @total_deuda decimal(6,2);
	if exists(select * from ESTUDIANTES where @ID_ESTUDIANTE = ID_ESTUDIANTE)
	BEGIN
		SELECT @total_deuda = ISNULL(SUM(monto),0) 
		from CUENTACORRIENTE 
		where id_estudiante = @ID_ESTUDIANTE 
		and id_estado_pago in(1,3)--DEUDA O PAGO PENDIENTE
		
		IF @total_deuda = 0
		BEGIN
			UPDATE ESTUDIANTES
			set estado = 'B'
			where id_estudiante = @id_estudiante;
		END
		ELSE
			PRINT('El alumno posee deudas y no puede ser dado de baja')
	END
	ELSE
	BEGIN
		PRINT('El alumno no existe');
	END
END
go;
--3.Crear un procedimiento que permita volver a dar de alta a un alumno
CREATE PROCEDURE darAlta
--4.Crear un procedimiento que permita matricular un alumno a un año. Solo se acepta una matricula por año por alumno. 
--El procedimiento además de validar los datos ingresados debe generar la factura correspondiente y el cargo en la cuenta corriente.
CREATE PROCEDURE matricularAlumno
--5.Crear un procedimiento que permita inscribir a un alumno a un curso. Además de verificar los datos ingresados
--debe verificar que el alumno no encuentre inscripto es ese u otro curso de la misma materia en ese cuatrimestre.
CREATE PROCEDURE inscribirAlumno
--6.Crear un procedimiento de le permita cargar nota a un alumno, debe recibir el curso, el alumno, el examen 
--y la nota. Debe validar los datos ingresados. Si la nota corresponde al recuperatorio verificar que al 
--menos una de las instancias anteriores es menor a 4. Si la nota corresponde al recuperatorio verificar 
--que no existan dos o más instancias de evaluaciones anteriores menores a 4.
CREATE PROCEDURE cargarNota
--7.Crear un procedimiento que permita generar las cuotas de todos los alumnos cada mes del cuatrimestre actual, 
--generando para ello la facturación y el cargo correspondiente a la cuenta corriente.
CREATE PROCEDURE generarCuotasAlumnos
--8.Crear un procedimiento que permita generar la cuota de un alumno determinado para un mes del cuatrimestre actual, 
--generando para ello la facturación y el cargo correspondiente a la cuenta corriente.
CREATE PROCEDURE generarCuotas
--9.Crear un procedimiento que calcule los intereses por mora para los alumnos que adeudan más de un mes de cuota.
CREATE PROCEDURE calculoInteresPorMora
--10.Crear un procedimiento que permita registrar un pago a un alumno determinado.
CREATE PROCEDURE registrarPago