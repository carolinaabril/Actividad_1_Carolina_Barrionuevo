--SELECT 

-- PROCEDIMIENTOS ALMACENADOS


-- FUNCIONES CON DEVOLUCION DE ESCALAR
-- 1.
select dbo.ObtenerSaldoEstudiante(100) as SaldoPendiente
-- 2.
select dbo.ObtenerVacantesDisponibles (9004) as VacantesDisponibles 
-- 3. 
select dbo.ObtenerNombreCompleto (500) as Nombre_completo
-- 4.
select dbo.ObtenerPromedioFinal(100,9001) as promedio_final

select dbo.ObtenerPromedioFinal(200, 9001) as promedio_final
-- 5. 
select.dbo.ObtenerEstadoPagoCuenta(200,3) as EstadoCuotaMarzo
-- 6.  
select dbo.ObtenerEspecialidad ('Laura', 'Lopez') as EspecialidadProfesor
-- 7. 
select dbo.ObtenerMontoAdeudado ('Ana') as MontoAdeudado


--FUNCIONES CON DEVOLUCION DE TABLAS
-- 1. 
select * from dbo.ListarCursosPorEstudiante('Ana')
-- 2. 
select * from dbo.CuotasImpagasEstudiante (100)
-- 3. 
select * from dbo.ProfesoresPorCuatrimestre(2)
-- 4. 
select * from dbo.MateriasCursosActivos (2025)
-- 5.
select*from dbo.EstudiantesMatriculadosAño(2025)
-- 6. 
select * from dbo.FacturasPorMes(2025,03)
-- 7. 
select*from dbo.CursosEstudiantesInscriptos ()
-- 8. 
select * from dbo.MovimientosCuentaCorrienteEstudiante(100)
-- 9. 
select * from dbo.Cursos_Profesor_Año(1111, 2025)
-- 10. 
select * from dbo.InscripcionesConNotaFinal ()


-- CURSORES CON PROCEDIMIENTOS ALMACENADOS (listados)


-- PROCEDIMIENTOS ALMACENADOS (SQL Dinámico) 
--1.
EXEC BuscarEstudiantesPorCampo @campo = 'apellido', @valor = 'Gomez'
--2.
exec FiltrarIscripciones
	@campo= 'nota_practica',
	@operador = '<',
	@valor = 6.00
-- 3.
exec CursosXInscriptos
	@campos_agrupacion='id_materia',
	@min_inscriptos=5
-- 4. 
exec ReporteFacturasAgrupacion @campo= 'id_estado_pago'

-- 5. 
exec ListarCuotasVencidas @campo_orden = 'fecha_vencimiento'

-- 6. 
exec CursosCondicionDinamica
	@campo = 'creditos',
	@operador = '>',
	@valor = 7

EXEC CursosCondicionDinamica 
    @campo = 'costo_mensual', 
    @operador = '>', 
    @valor = 12000

-- 7. 
exec CursosProfesoresXCuatrimestre
	@id_cuatrimestre = 2,
	@campo_orden = 'nombre'

exec CursosProfesoresXCuatrimestre
	@id_cuatrimestre = 1,
	@campo_orden = 'apellido'

-- 8. 
exec MovimientosPorConceptos @conceptos = 'matrícula,cuota,interés'

-- 9. 
exec InscripcionesPorColumnas
	@columnas = 'nota_teorica_1,nota_practica,nota_final'

-- 10.

exec ListadoEstudiantesFiltros 
	@condiciones = 'id_estudiante=700'

exec ListadoEstudiantesFiltros
	@condiciones = 'anio_ingreso > 2022 and apellido like ''%Blanco%'''


--TRIGGERS


--TRANSACCIONES DESDE PROCEDIMIENTOS ALMACENADOS