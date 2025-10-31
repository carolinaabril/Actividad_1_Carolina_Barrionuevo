--Procedimiento almacenado (SQL Din�mico) 
-- 1.	Listar estudiantes seg�n un campo de b�squeda variable (nombre, apellido, email, a�o de ingreso), definido por el usuario. 

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
		where ' + quotename (@campo) + ' =@valor_parametro'      -- proteje nombres de objetos contra inyecci�n sql

	exec sp_executesql @sql, N'@valor_parametro nvarchar(100)', @valor_parametro = @valor

end 

EXEC BuscarEstudiantesPorCampo @campo = 'apellido', @valor = 'Gomez'


-- 2.	Consultar inscripciones filtrando por una combinaci�n din�mica de notas (por ejemplo, nota_teorica_1, nota_pr�ctica, nota_final) y operador (menor, mayor, igual). 

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

-- 3.	Listar cursos que tengan m�s de X inscriptos, donde X es un par�metro, y el campo de agrupaci�n puede ser por a�o, materia o profesor. 
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

-- 4.	Generar un reporte de facturas agrupadas por un campo din�mico (mes, estado_pago, estudiante). 

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

-- 5.	Listar cuotas vencidas ordenadas por un campo din�mico (fecha_vencimiento, monto, estado_pago). 
-- 6.	Mostrar los cursos que cumplen con una condici�n din�mica (por ejemplo, costo mensual > X, cr�ditos < Y, a�o = Z). 
-- 7.	Listar profesores que dictan cursos en un cuatrimestre espec�fico, con posibilidad de ordenar por nombre, apellido o especialidad. 
-- 8.	Consultar movimientos de cuenta corriente filtrando por m�ltiples conceptos seleccionados por el usuario (por ejemplo, 'matr�cula', 'cuota', 'inter�s'). 
-- 9.	Listar inscripciones donde el usuario define qu� columnas mostrar (por ejemplo, nota_final, nota_teorica_1, nota_practica). 
-- 10.	Generar un listado de estudiantes con filtros din�micos combinados (por ejemplo, a�o_ingreso > X AND apellido LIKE '%Y%'). 