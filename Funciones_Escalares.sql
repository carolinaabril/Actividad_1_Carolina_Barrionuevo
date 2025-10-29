--Funciones con devolucion de un ESCALAR! 
-- 1.Crear una función que permita conocer el saldo de la cuenta corriente de un alumno determinado.
--select * from CUENTACORRIENTE

create function dbo.ObtenerSaldoEstudiante (@id_estudiante int)
returns decimal (10,2)
as
begin
	declare @Saldo decimal (10,2)

	select @Saldo = isnull (sum(monto), 0)
	from CUENTACORRIENTE
	where id_estudiante = @id_estudiante
	and id_estado_pago = 2 -- (2) Movimientos pendientes/ (1) Pagado

	return @Saldo

end



-- 2.Crear una función de devuelva la cantidad de vacantes de un curso, tomando como parámetro que cada curso puede tener como máximo 35 alumnos. 
create function dbo.ObtenerVacantesDisponibles (@id_curso int)

returns int
as
begin
	declare @Vacantes int 

	select @Vacantes = 35 - count(*)
	from INSCRIPCIONES
	where id_curso = @id_curso

	return @Vacantes

end 


-- 3. Obtener el nombre completo de un estudiante dado su ID. 
create function dbo.ObtenerNombreCompleto(@id_estudiante int)
returns varchar(100)
as
begin 
	declare @Nombre_completo varchar(100)

	select @Nombre_completo = CONCAT (nombre, ' ', apellido)
	from ESTUDIANTES
	where id_estudiante = @id_estudiante

	return @Nombre_completo

end


-- 4. Calcular el promedio final de un estudiante en un curso específico. 
create function dbo.ObtenerPromedioFinal (@id_estudiante int, @id_curso int)

returns float
as
begin
	declare @Promedio float

	select @Promedio = 
		case
			when nota_teorica_recuperatorio is null then 
				(nota_teorica_1 + nota_teorica_2 + nota_practica) /3.0
			else (nota_teorica_1 + nota_teorica_2 + nota_practica + nota_teorica_recuperatorio) /4.0
		end
	from INSCRIOCIONES
	where id_estudiante =@id_estudiante and id_curso = @id_curso;

	return @Promedio;

end
----------------------
alter function dbo.ObtenerPromedioFinal (@id_estudiante int, @id_curso int)

returns float
as
begin
	declare @Promedio float

	select @Promedio = 
		case
			when nota_teorica_recuperatorio is null then 
				(nota_teorica_1 + nota_teorica_2 + nota_practica) /3.0

			else (nota_teorica_1 + nota_teorica_2 + nota_practica + nota_teorica_recuperatorio) /4.0

		end
	from INSCRIPCIONES
	where id_estudiante =@id_estudiante and id_curso = @id_curso;

	return @Promedio;

end

	
	
-- 5. Determinar el estado de pago de una cuota específica de un estudiante. 
create function dbo.ObtenerEstadoPagoCuenta (@id_estudiante int, @mes int)

returns varchar (20)
as
begin 
	declare @EstadoDePago varchar(20)

	select @EstadoDePago = 
		case
			when id_estado_pago = 1 then 'PENDIENTE'
			when id_estado_pago = 2 then 'PAGA'
			else 'VENCIDA'
		end
	from cuota
	where id_estudiante = @id_estudiante and mes = @mes

	return isnull (@EstadoDePago, 'No existe')

end 

-- 6.  La especialidad de un profesor dado el nombre del profesor. 
create function dbo.ObtenerEspecialidad (@nombre varchar (50), @apellido varchar (50))
returns varchar (100)
as
begin
	declare @Especialidad varchar (100)

	select @Especialidad = especialidad
	from PROFESORES
	where nombre = @nombre and apellido = @apellido

	return isnull (@Especialidad, 'No encontrada')
end


-- 7. Calcular el monto total adeudado por un estudiante pasándole el nombre como parámetro. Si existe más de un estudiante con ese nombre devolver -1. 
create function dbo.ObtenerMontoAdeudado (@nombre varchar (50))

returns decimal (10,2)
as
begin
	declare @MontoTotal decimal (10,2)
	declare @IdEstudiante int 

-- verificamos si hay mas estudiantes con ese nombre 
	if (select count (*) from ESTUDIANTES where nombre = @nombre) > 1
		return -1

	select @IdEstudiante = id_estudiante
	from ESTUDIANTES
	where nombre = @nombre


	select @MontoTotal = isnull(sum(monto), 0)
	from cuota
	where id_estudiante = @IdEstudiante and id_estado_pago = 1

	return @MontoTotal

end

--------------------------------------------------------------------

alter function dbo.ObtenerMontoAdeudado (@nombre varchar(50))
returns decimal(10,2)
as
begin
    declare @MontoTotal decimal (10,2)
	declare @IdEstudiante int 

	if (select count (*) from ESTUDIANTES where nombre = @nombre) > 1
		return -1

	select @IdEstudiante = id_estudiante
	from ESTUDIANTES
	where nombre = @nombre

	select @MontoTotal = isnull(sum(monto), 0)
	from cuota
	where id_estudiante = @IdEstudiante and id_estado_pago = 1

	return @MontoTotal
end