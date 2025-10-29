--Funciones con devolucrion de TABLAS
-- 1. Listar todos los cursos en los que está inscripto un estudiante. 

select * from dbo.ListarCursosPorEstudiante('Ana')

-- 2. Obtener todas las cuotas impagas de un estudiante. 

select * from dbo.CuotasImpagasEstudiante (100)

-- 3. Listar los profesores que dictan materias en un cuatrimestre específico. 

select * from dbo.ProfesoresPorCuatrimestre(2)

-- 4. Mostrar todas las materias con más de 3 cursos activos. 

select * from dbo.MateriasCursosActivos (2025)

-- 5. Listar los estudiantes con matrícula activa en un año determinado. 

select*from dbo.EstudiantesMatriculadosAño(2025)

-- 6. Obtener todas las facturas emitidas en un mes específico. 

select * from dbo.FacturasPorMes(2025,03)

-- 7. Listar los cursos con más de 30 estudiantes inscriptos. 

select*from dbo.CursosEstudiantesInscriptos ()

-- 8. Mostrar los movimientos de cuenta corriente de un estudiante. 

select * from dbo.MovimientosCuentaCorrienteEstudiante(100)

-- 9. Listar los cursos dictados por un profesor en un año específico. 

select * from dbo.Cursos_Profesor_Año(1111, 2025)

-- 10. Obtener todas las inscripciones con nota final mayor a 8. 

select * from dbo.InscripcionesConNotaFinal ()