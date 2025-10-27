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
CREATE PROCEDURE cargaCurso
@id int,
@nombre varchar(100),
@descripcion varchar(100),
@anio int,
@id_prof int,
@id_materia int
AS
BEGIN
    -- Verificar que el profesor exista
    IF NOT EXISTS (SELECT 1 FROM PROFESORES WHERE id_profesor = @id_profesor)
    BEGIN
        PRINT 'Error: el profesor especificado no existe.';
        RETURN;
    END

    -- Verificar que la materia exista
    IF NOT EXISTS (SELECT 1 FROM MATERIAS WHERE id_materia = @id_materia)
    BEGIN
        PRINT 'Error: la materia especificada no existe.';
        RETURN;
    END

    -- Si todo está bien, insertar el curso
    INSERT INTO CURSOS (id_curso, nombre_curso, descripcion, anio, id_profesor, id_materia)
    VALUES (@id_curso, @nombre_curso, @descripcion, @anio, @id_profesor, @id_materia);

    PRINT 'Curso cargado correctamente.';
END;
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
CREATE PROCEDURE cargaCuatrimestre
CREATE PROCEDURE cargaInteresPorMora


--2.Crear un procedimiento que permita dar de baja a un alumno. El mismo debe contemplar que la cuenta corriente
--este en cero para hacerlo. No debe borrarse el historial del alumno, solo indicar que esta de baja.

--3.Crear un procedimiento que permita volver a dar de alta a un alumno

--4.Crear un procedimiento que permita matricular un alumno a un año. Solo se acepta una matricula por año por alumno. 
--El procedimiento además de validar los datos ingresados debe generar la factura correspondiente y el cargo en la cuenta corriente.

--5.Crear un procedimiento que permita inscribir a un alumno a un curso. Además de verificar los datos ingresados
--debe verificar que el alumno no encuentre inscripto es ese u otro curso de la misma materia en ese cuatrimestre.

--6.Crear un procedimiento de le permita cargar nota a un alumno, debe recibir el curso, el alumno, el examen 
--y la nota. Debe validar los datos ingresados. Si la nota corresponde al recuperatorio verificar que al 
--menos una de las instancias anteriores es menor a 4. Si la nota corresponde al recuperatorio verificar 
--que no existan dos o más instancias de evaluaciones anteriores menores a 4.

--7.Crear un procedimiento que permita generar las cuotas de todos los alumnos cada mes del cuatrimestre actual, 
--generando para ello la facturación y el cargo correspondiente a la cuenta corriente.

--8.Crear un procedimiento que permita generar la cuota de un alumno determinado para un mes del cuatrimestre actual, 
--generando para ello la facturación y el cargo correspondiente a la cuenta corriente.

--9.Crear un procedimiento que calcule los intereses por mora para los alumnos que adeudan más de un mes de cuota.

--10.Crear un procedimiento que permita registrar un pago a un alumno determinado.