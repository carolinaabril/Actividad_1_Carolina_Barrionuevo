--Procedimiento almacenado (SQL Dinámico) 
-- 1.	Listar estudiantes según un campo de búsqueda variable (nombre, apellido, email, año de ingreso), definido por el usuario. 

create procedure BuscarEstudiantesPorCampo
	@campo nvarchar(50),
	@valor nvarchar (100)

as
begin
	declare @sql nvarchar(max)

	if @campo not in ('nombre','apellido', 'email', 'anio_ingreso')
	begin 
	 raiserror ('Campo de busqueda no valido', 16,1)  --error personalizado
	 return
	end


	set @sql = '
		select id_estudiante, nombre, apellido, email, anio_ingreso
		from ESTUDIANTES
		where ' + quotename (@campo) + ' =@valor_parametro'      -- proteje nombres de objetos contra inyección sql

	exec sp_executesql @sql, N'@valor_parametro nvarchar(100)', @valor_parametro = @valor

end 

EXEC BuscarEstudiantesPorCampo @campo = 'apellido', @valor = 'Gomez'


-- 2.	Consultar inscripciones filtrando por una combinación dinámica de notas (por ejemplo, nota_teorica_1, nota_práctica, nota_final) y operador (menor, mayor, igual). 

create procedure  FiltrarIscripciones
	@campo nvarchar(50),
	@operador nvarchar(2),
	@valor decimal (4,2)

as
begin
	declare @sql nvarchar (max)
	set @sql = '
		select id_estudiante, id_curso, fecha_inscripcion , ' + QUOTENAME(@campo) + '
		from INSCRIPCIONES
		where ' + QUOTENAME (@campo) + ' ' + @operador + '@valor_param'

		exec sp_executesql @sql, 
			N'@valor_param decimal (4,2)',
			@valor_param = @valor

end 

exec FiltrarIscripciones
	@campo= 'nota_practica',
	@operador = '<',
	@valor = 6.00

-- 3.	Listar cursos que tengan más de X inscriptos, donde X es un parámetro, y el campo de agrupación puede ser por año, materia o profesor. 
create procedure CursosXInscriptos 
	@campos_agrupacion nvarchar (50),
	@min_inscriptos int

as
begin 
	declare @sql nvarchar (max)

	set @sql = '
		select c.' + QUOTENAME (@campos_agrupacion) + ', count(i.id_estudiante) as cantidad_inscriptos
		from CURSOS c 
		join INSCRIPCIONES i on c.id_curso = i.id_curso
		group by c.' + QUOTENAME (@campos_agrupacion) + '
		having count (i.id_estudiante) > @min_parametro'

	exec sp_executesql @sql,
		N'@min_parametro int',
		@min_parametro = @min_inscriptos
end

exec CursosXInscriptos
	@campos_agrupacion='id_materia',
	@min_inscriptos=5

-- 4.	Generar un reporte de facturas agrupadas por un campo dinámico (mes, estado_pago, estudiante). 

create procedure ReporteFacturasAgrupacion 
	@campo nvarchar (50)

as
begin
	declare @sql nvarchar(max)
	declare  @selectCampo nvarchar(100)

	if @campo = 'mes'
		set @selectCampo = 'month(fecha)'
	else
		set @selectCampo = QUOTENAME (@campo)

	set @sql = '
		select ' + @selectCampo + ' AS agrupado_por, sum(monto) AS total_facturado, count (*) AS cantidad_movimientos
		from CUENTACORRIENTE
		group by ' + @selectCampo + ' 
		order by ' + @selectCampo

	exec sp_executesql @sql
end

-- 5.	Listar cuotas vencidas ordenadas por un campo dinámico (fecha_vencimiento, monto, estado_pago). 

alter procedure ListarCuotasVencidas
	@campo_orden nvarchar (50)

as
begin
	declare @sql nvarchar(max)

	set @sql = ' 
		select c.id_cuota, c.id_estudiante, c.id_factura, f.fecha_vencimiento, f.monto_total, f.id_estado_pago
		from cuota c
		join factura f on c.id_factura = f.id_factura
		where f.fecha_vencimiento < getdate()
		order by ' + QUOTENAME (@campo_orden)

	exec sp_executesql @sql
end


-- 6.	Mostrar los cursos que cumplen con una condición dinámica (por ejemplo, costo mensual > X, créditos < Y, año = Z). 

create procedure CursosCondicionDinamica
	@campo nvarchar(50),
	@operador nvarchar (2),
	@valor numeric (10,2)

as
begin
	declare @sql nvarchar(max)

	set @sql = '
	select id_curso, nombre_curso, anio, creditos, id_profesor, id_materia
	from CURSOS
	where ' + QUOTENAME(@campo) + ' ' + @operador + ' @valor_param'


	exec sp_executesql @sql,
		N'@valor_param int',
		@valor_param = @valor
end 
-- 7.	Listar profesores que dictan cursos en un cuatrimestre específico, con posibilidad de ordenar por nombre, apellido o especialidad. 

alter procedure CursosProfesoresXCuatrimestre
	@id_cuatrimestre int,
	@campo_orden nvarchar(50)

as
begin
	declare @sql nvarchar (max)
	set @sql = '
		select distinct p.id_profesor, p.nombre, p.apellido, p.especialidad
		from PROFESORES p
		join CURSOS c on p.id_profesor=c.id_profesor
		where c.id_cuatrimestre = @cuatrimestre_param
		order by ' + QUOTENAME(@campo_orden)

	exec sp_executesql @sql,
		N'@cuatrimestre_param int',
		@cuatrimestre_param =@id_cuatrimestre

end

-- 8.	Consultar movimientos de cuenta corriente filtrando por múltiples conceptos seleccionados por el usuario (por ejemplo, 'matrícula', 'cuota', 'interés'). 

alter procedure MovimientosPorConceptos
	@conceptos nvarchar(max) -- ['matricula, cuota, interes']
as
begin
	declare @listaConceptos nvarchar(max)
	declare @sql nvarchar(max)

	select @listaConceptos = STRING_AGG('''' + trim(value) + '''', ',')
	from STRING_SPLIT (@conceptos, ',') 

	set @sql = '
		select cc.id_movimiento, cc.id_estudiante, cc.fecha, cc.concepto, cc.monto, cc.id_estado_pago
		from CUENTACORRIENTE cc
		where cc.concepto in (' + @listaConceptos + ')'

	exec (@sql)
end

-- 9.	Listar inscripciones donde el usuario define qué columnas mostrar (por ejemplo, nota_final, nota_teorica_1, nota_practica). 

alter procedure InscripcionesPorColumnas
	@columnas nvarchar(max) 
as
begin
	declare @sql nvarchar(max)

	set @sql = ' 
		select id_curso, id_estudiante, ' + @columnas + '
		from INSCRIPCIONES'
	exec (@sql)
end
-- 10.	Generar un listado de estudiantes con filtros dinámicos combinados (por ejemplo, año_ingreso > X AND apellido LIKE '%Y%'). 

create procedure ListadoEstudiantesFiltros
	@condiciones nvarchar(max)
as
begin
	declare @sql nvarchar(max)

	set @sql = '
		select id_estudiante, nombre, apellido, email, anio_ingreso
		from ESTUDIANTES
		where ' + @condiciones
		
	exec (@sql)
end




