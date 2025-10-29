--Funciones con devolucrion de TABLAS
-- 1. Listar todos los cursos en los que está inscripto un estudiante.
create function dbo.ListarCursosPorEstudiante (@nombre varchar (50))

returns table
as 
return (select c.id_curso, c.nombre_curso
	from ESTUDIANTES e
	join INSCRIPCIONES i on e.id_estudiante = i.id_estudiante
	join CURSOS c on i.id_curso = c.id_curso
	where e.nombre = @nombre
	)


-- 2. Obtener todas las cuotas impagas de un estudiante.
create function dbo.CuotasImpagasEstudiante (@id_estudiante int)

returns table
as 
return (select c.id_cuota, c.mes, c.monto, c.fecha_vencimiento
	from ESTUDIANTES e
	join cuota c on e.id_estudiante = c.id_estudiante
	where e.id_estudiante = @id_estudiante
		and c.id_estado_pago = 1 --PENDIENTE

	)
-----------------------------
alter function dbo.CuotasImpagasEstudiante (@id_estudiante int)

returns table
as 
return(select c.id_estudiante, c.id_cuota, c.mes, c.monto, c.fecha_vencimiento
	from ESTUDIANTES e
	join cuota c on e.id_estudiante = c.id_estudiante
	where e.id_estudiante = @id_estudiante
		and c.id_estado_pago = 1 --PENDIENTE
	)

-- 3. Listar los profesores que dictan materias en un cuatrimestre específico. 

create function dbo.ProfesoresPorCuatrimestre (@id_cuatrimestre int)
returns table
as
return (select distinct p.id_profesor, p.nombre, p.apellido
	from PROFESORES p
	join CURSOS m on p.id_profesor = m.id_profesor
	join CUATRIMESTRE c on m.id_cuatrimestre = c.id_cuatrimestre
	where c.id_cuatrimestre = @id_cuatrimestre
	)

-- 4. Mostrar todas las materias con más de 3 cursos activos.  

create function dbo.MateriasCursosActivos (@anio int)
returns table
as
return (select m.id_materia, m.nombre_materia,
	count (c.id_curso) as cantidad_cursos
	from MATERIAS m
	join Cursos c on m.id_materia = c.id_materia
	where c.anio=@anio
	group by m.id_materia, m.nombre_materia
	having count (c.id_curso) > 3
	)
-- 5. Listar los estudiantes con matrícula activa en un año determinado. 
create function dbo.EstudiantesMatriculadosAño(@anio int)
returns table
as 
return (select e.id_estudiante, e.nombre
	from ESTUDIANTES e
	join matriculacion m on e.id_estudiante = m.id_estudiante
	where m.anio=@anio
	group by e.id_estudiante, e.nombre
	)

-- 6. Obtener todas las facturas emitidas en un mes específico. 
create function dbo.FacturasPorMes (@anio int, @mes int)
returns table
as 
return(select * from factura
	where year (fecha_emision) = @anio and month (fecha_emision) = @mes
	)

-- 7. Listar los cursos con más de 30 estudiantes inscriptos. 

create function dbo.CursosEstudiantesInscriptos ()
returns table
as
return (select c.id_curso, c.nombre_curso, count (i.id_estudiante) as cantidad_inscriptos
	from CURSOS c
	join INSCRIPCIONES i on c.id_curso = i.id_curso
	group by c.id_curso, c.nombre_curso
	having count (i.id_estudiante) > 30
	)

-- 8. Mostrar los movimientos de cuenta corriente de un estudiante. 
create function dbo.MovimientosCuentaCorrienteEstudiante (@id_estudiante int)
returns table
as
return (select cc.id_movimiento, cc.fecha, cc.concepto, cc.monto, ep.nombre_esatdo as esatdo_pago

	from CUENTACORRIENTE cc
	join ESTADOS_PAGO ep on cc.id_estado_pago = ep.id_estado_pago
	where cc.id_estudiante =@id_estudiante
	)
------------------------------
alter function dbo.MovimientosCuentaCorrienteEstudiante (@id_estudiante int)
returns table
as
return (select cc.id_movimiento, cc.fecha, cc.concepto, cc.monto, ep.nombre_estado as esatdo_pago

	from CUENTACORRIENTE cc
	join ESTADOS_PAGO ep on cc.id_estado_pago = ep.id_estado_pago
	where cc.id_estudiante =@id_estudiante
	)

-- 9. Listar los cursos dictados por un profesor en un año específico. 

create function dbo.Cursos_Profesor_Año (@id_profesor int, @anio int)
returns table
as
return (select id_curso, nombre_curso, descripcion, anio
	from CURSOS
	where id_profesor=@id_profesor
	and anio = @anio)

-- 10. Obtener todas las inscripciones con nota final mayor a 8. 

create function dbo.InscripcionesConNotaFinal()
returns table
as
return (select * 
	from INSCRIPCIONES
	where nota_final > 8
	)