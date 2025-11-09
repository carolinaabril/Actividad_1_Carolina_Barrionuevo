--SELECT 

-- PROCEDIMIENTOS ALMACENADOS
--1
exec cargaAlumnos 
	@id = 1300,
	@nombre = 'Ignacio',
	@apellido = 'Gutierrez',
	@email = 'Ignacio@example.com',
	@anio_ingreso = 2025;

EXEC cargaAlumnos
	@id = 1400, 
	@nombre = 'Mariana', 
	@apellido = 'Lopez', 
	@email = 'mariana@example.com',
	@anio_ingreso = 2025;

EXEC cargaMateria --VER
    @id = 510,
    @nombre_materia = 'Química General',
    @creditos = 5; 

EXEC cargaProfesor
    @id = 8888,
    @nombre = 'Mariana',
    @apellido = 'Torres',
    @especialidad = 'Química';

EXEC cargaCurso --VER
    @id = 9200,
    @nombre = 'Curso Química General',
    @descripcion = 'Básico',
    @anio = 2025,
    @id_prof = 8888,
    @id_materia = 510;

EXEC cargaCuatrimestre
    @id = 3,
    @nombre = 'Cuatrimestre 3 2025',
    @inicio = '2025-12-15',
    @fin = '2026-02-28';

EXEC cargaInteresPorMora
    @anio = 7,
    @porcentaje = 2.5;
--2
EXEC darBaja @ID_ESTUDIANTE = 1400;
--3
EXEC darAlta @id = 1400;
--4
EXEC matricularAlumno 
	@id_alumno = 300, 
	@anio_a_matricular = 2025, 
	@monto_mat = 5000;
--5
EXEC matricularAlumno 
	@id_alumno = 400, 
	@anio_a_matricular = 2025, 
	@monto_mat = 5000;
--6
EXEC inscribirAlumno 
	@id_alumno = 600, 
	@id_curso = 9005;

EXEC inscribirAlumno 
	@id_alumno = 100, 
	@id_curso = 9005;
--7
EXEC cargarNota 
	@id_curso = 9005, 
	@id_alumno = 100, 
	@examen = 'nota_teorica_1', 
	@nota = 9;

EXEC cargarNota 
	@id_curso = 9005, 
	@id_alumno = 100, 
	@examen = 'nota_teorica_2', 
	@nota = 2;

EXEC cargarNota 
	@id_curso = 9005, 
	@id_alumno = 100, 
	@examen = 'nota_teorica_recuperatorio', 
	@nota = 7;
--8
EXEC generarCuotasAlumnos; --ver
--9
EXEC generarCuota 
	@id_alumno = 500, 
	@id_cuatri = 2, 
	@mes = 8, 
	@monto = 1200, 
	@fecha_emision = '2025-08-01', 
	@anio = 2025;
--10
EXEC calculoInteresPorMora; 

EXEC registrarPago 
	@id_alumno = 100, 
	@id_factura = 1, 
	@concepto = 'Pago Cuota Marzo';

EXEC registrarPago 
	@id_alumno = 200, 
	@id_factura = 2, 
	@concepto = 'Pago Cuota Marzo';

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
--1
EXEC dbo.sp_EstudiantesNotasFinalesPorCurso
--2
EXEC dbo.sp_HistorialPagosPorEstudiante;
--3
EXEC dbo.sp_MateriasProfesoresCursos
--4
EXEC dbo.sp_InscripcionesPorCuatrimestreYCurso
--5
EXEC dbo.sp_EstudianteConCuotasVencidas
--6
EXEC dbo.sp_CursosConCantidadInscriptos
--7
EXEC dbo.sp_FacturasAgrupadasPorEstado
--8
EXEC dbo.sp_InteresesPorMora
--9
EXEC dbo.sp_TopCursosPorInscripciones
--10
EXEC dbo.sp_EstudiantesSinMatriculaActual

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

SELECT * FROM ESTUDIANTES;
SELECT * FROM profesores;
SELECT * FROM MATERIAS; 
SELECT * FROM CURSOS;
SELECT * FROM INSCRIPCIONES;
SELECT * FROM CUATRIMESTRE;
SELECT * FROM MATRICULACION;
SELECT * FROM FACTURA;
SELECT * FROM CUOTA;
SELECT * FROM ITEMFACTURA;
SELECT * FROM INTERESPORMORA;
SELECT * FROM CUENTACORRIENTE;