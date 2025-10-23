--ver cuales son referidas y cuales referentes

CREATE table ESTUDIANTES( --referente
id_estudiante int not null,
nombre varchar(50)not null,
apellido varchar(50)not null,
email varchar(50) not null,

constraint pk_estudiante primary key (id_estudiante)
)
--agrega año de ingreso del estudiante
ALTER TABLE ESTUDIANTES
ADD anio_ingreso INT NULL;


CREATE table PROFESORES( --referente
id_profesor int not null,
nombre varchar(30) not null,
apellido varchar(30) not null,
especialidad varchar(60)not null,

constraint pk_profesor primary key(id_profesor)
)

CREATE table MATERIAS( --referente
id_materia int not null,
nombre_materia varchar(50) not null,
creditos int not null,
costo_curso_mensual decimal(6,2),

constraint pk_materia primary key(id_materia)

)

CREATE table CURSOS( --referida y referente
id_curso int not null,
nombre_curso varchar(100) not null,
descripcion varchar(100),
anio int not null,
id_profesor int not null,
id_materia int not null,

constraint pk_cursos primary key (id_curso),
constraint fk_profesor foreign key(id_profesor) references PROFESORES(id_profesor), --(id_profesor es una columna)
constraint fk_materia foreign key(id_materia) references MATERIAS(id_materia)
)


CREATE TABLE INSCRIPCIONES( --referida
    id_estudiante INT NOT NULL,
    id_curso INT NOT NULL,
    fecha_inscripcion DATE NOT NULL, 
    nota_teorica DECIMAL(4,2) NOT NULL, --cambiar nombre a nota_teorica_1
        CONSTRAINT chk_nota_teorica CHECK (nota_teorica BETWEEN 1 AND 10),
    --nota_teorica_2 decimal(4,2) not null,
    --    constraint chk_nota_teorica2 check (nota_teorica_2 between 1 and 10)
    nota_practica DECIMAL(4,2) NOT NULL,
        CONSTRAINT chk_nota_practica CHECK (nota_practica BETWEEN 1 AND 10),
    --nota_teorica_recuperatorio decimal(4,2) null,
    nota_final AS ((nota_teorica + nota_practica)/2.0),  -- columna calculada

    CONSTRAINT pk_estudianteInscripto PRIMARY KEY(id_estudiante, id_curso),
    CONSTRAINT fk_estudiante FOREIGN KEY (id_estudiante) REFERENCES ESTUDIANTES(id_estudiante),
    CONSTRAINT fk_curso FOREIGN KEY (id_curso) REFERENCES CURSOS(id_curso)
);
EXEC sp_rename 'INSCRIPCIONES.nota_teorica', 'nota_teorica_1', 'COLUMN';
ALTER TABLE INSCRIPCIONES 
DROP CONSTRAINT chk_nota_teorica;

ALTER TABLE INSCRIPCIONES
ADD CONSTRAINT chk_nota_teorica_1 CHECK (nota_teorica_1 BETWEEN 1 AND 10);


CREATE TABLE CUATRIMESTRE(
    id_cuatrimestre int not null,
    nombre varchar(100) not null,
    fecha_inicio date not null,
    fecha_fin date not null,

    constraint pk_id_cuatrimestre primary key(id_cuatrimestre)
);

create table ESTADOS_PAGO(
id_estado_pago INT,
    nombre_estado VARCHAR(20) NOT NULL 
);
INSERT INTO ESTADOS_PAGO (id_estado_pago, nombre_estado)
VALUES (1, 'PENDIENTE'),
       (2, 'PAGA'),
       (3, 'VENCIDA');

create table factura(
id_factura int not null,
id_estudiante int not null,
mes int not null,
constraint chk_mes check (mes between 1 and 12), 
anio int not null,
fecha_emision date not null,
fecha_vencimiento date not null,
monto_total decimal(6,2) not null,
CONSTRAINT chk_monto_total CHECK (monto_total > 0),
id_estado_pago int not null,
constraint fk_estado_pago foreign key (id_estado_pago) references ESTADOS_PAGO(id_estado_pago),

CONSTRAINT pk_id_factura primary key(id_factura),
constraint fk_id_estudiante foreign key (id_estudiante) references estudiantes(id_estudiante)
);

create table cuota(
id_cuota int not null,
id_estudiante int not null,
id_cuatrimestre int not null,
id_factura int not null,
mes int not null,
constraint chk_mes check (mes between 1 and 12),
monto decimal(6,2) not null,
constraint chk_monto_cuota check(monto > 0),
fecha_vencimiento date not null,
id_estado_pago int not null,
constraint fk_estado_pago foreign key (id_estado_pago) references ESTADOS_PAGO(id_estado_pago),
constraint pk_cuota primary key(id_cuota),  
constraint fk_id_estudiante foreign key (id_estudiante) references estudiantes(id_estudiante),
constraint fk_id_cuatrimestre foreign key (id_cuatrimestre) references cuatrimestre(id_cuatrimestre),
constraint fk_id_factura foreign key(id_factura) references factura(id_factura)
);

create table matriculacion(
id_matricula int not null,
id_estudiante int not null, 
anio int not null,
fecha_pago date not null,
monto decimal(6,2) not null,
constraint chk_monto_matriculacion check(monto > 0),
id_estado_pago int not null,
constraint fk_estado_pago foreign key (id_estado_pago) references ESTADOS_PAGO(id_estado_pago),

constraint pk_id_matricula primary key(id_matricula),
constraint fk_id_estudiante foreign key (id_estudiante) references estudiantes(id_estudiante)
);

create table CUENTACORRIENTE(
id_movimiento int not null,
id_estudiante int not null,
fecha date not null,
concepto varchar(100) not null,
monto decimal(6,2) not null,
constraint chk_monto_cuenta_corriente check(monto > 0),
estado varchar(15) not null, --que estados puede tener la cuenta corriente?
constraint chk_estado check (estado in ('PENDIENTE','PAGA','VENCIDA')),

CONSTRAINT pk_id_movimiento primary key(id_movimiento),
constraint fk_id_estudiante foreign key (id_estudiante) references estudiantes(id_estudiante)
);

create table INTERESPORMORA(
anio_carrera INT NOT NULL,
porcentaje_interes decimal (5,2) not null,
constraint chk_porcentaje_interes check (porcentaje_interes >= 0),

CONSTRAINT pk_anio_carrera primary key(anio_carrera)
);

CREATE TABLE itemFactura (
    id_factura INT NOT NULL,
    id_curso INT NOT NULL,
    PRIMARY KEY (id_factura, id_curso),
    CONSTRAINT FK_ItemFactura_Factura FOREIGN KEY (id_factura) REFERENCES Factura(id_factura),
    CONSTRAINT FK_ItemFactura_Curso FOREIGN KEY (id_curso) REFERENCES Cursos(id_curso)
);

--prueba