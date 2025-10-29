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

-- 6. Obtener todas las facturas emitidas en un mes específico. 


-- 7. Listar los cursos con más de 30 estudiantes inscriptos. 
-- 8. Mostrar los movimientos de cuenta corriente de un estudiante. 
-- 9. Listar los cursos dictados por un profesor en un año específico. 
-- 10. Obtener todas las inscripciones con nota final mayor a 8. 