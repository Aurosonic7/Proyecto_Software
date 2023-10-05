 create user Brayan identified by  "1";
grant connect to Brayan with admin option;
grant dba to Brayan with admin option;

--Creación de tablas:
--Creación de la tabla Persona:
Create table Persona(
Matricula integer null,
Nombre varchar2(20) not null,
A_Pat varchar2(20) not null,
A_Mat varchar2(20)not null,
Semestre integer  null,
Correo varchar2(50) not null,
Carrera varchar2(50) null,
Contrasena varchar2(50) not null,
rol integer not null,
primary key (Matricula)
);
select * from registro;
select sysdate from dual;
--Creación de la tabla Registro
Create table Registro(
ID_Registro integer not null,
Matricula integer not null,
ID_Empresa integer not null,
Cat_Serv varchar2(20),
Fech_Fin date not null,
Fech_Inic date not null,
Edo_Serv varchar2(10)  null,
H_Faltantes integer  null,
H_Totales integer not null,
H_Realizadas Integer not null,
primary key(ID_Registro)
);



--Creación de la tabla Empresa
Create table Empresa(
ID_Empresa integer not null,
Nombre_Empresa varchar2(20) not null,
Tel varchar2(20) not null,
Direccion varchar2(30) not null,
primary key(ID_Empresa)
);

--delete from empresa;
--delete from Registro;
--delete from Persona;


--select * from Empresa;

--select * from Registro;

--select * from Persona;

--Creación de las claves foraneas
alter table Registro add constraint FK$REGISTRO$MATRICULA foreign key (Matricula) references Persona(Matricula);
alter table Registro add constraint FK$REGISTRO$ID_EMPRESA foreign key (ID_Empresa) references Empresa(ID_Empresa);



--Creación de Trigger para autoincrementar el ID_Alumno de la tabla alumno
--create or replace trigger AUTOINCREMENT_PERSONA
  --before insert on Persona  
  --for each row
--declare
  --max_id_persona number;
--begin
  --select max(Matricula) + 1 into max_id_persona from persona;
  --:new.id_persona := max_id_persona;
--end AUTOINCREMENT_PERSONA;


--Prueba de insercción de datos de ejemplo para la tabla persona registrando a un alumno
Insert into Persona(Matricula,nombre,a_pat,a_mat,semestre,correo,carrera,contrasena,Rol) 
values(014427690,'Brayan','Aguilar','Jarquin',1,'Brayan2noe@gmail.com','Ingenieria en Software','12345678',1);

--Prueba de insercción de datos de ejemplo para la tabla persona registrando a un admin
Insert into Persona(Matricula,nombre,a_pat,a_mat,correo,contrasena,Rol) 
values(014428680,'Juan','Mendez','Joaquin','JuanMendez@gmail.com','1234dsf',0);

insert into Empresa(Id_Empresa,Nombre_Empresa,Tel,Direccion)
values(-15478,'Spectra','951','centro');
insert into Empresa(id_empresa,Nombre_Empresa,Tel,Direccion)
values(-56,'aasd','750','adasd');

select * from empresa;
select *
--Creacion de la vista para la exportación de horas
--Se requerira:
--Matricula, Nombre, Carrera, Tipo de servicio, Empresa, Fecha de inicio, Horas realizadas
--Necesito Categoria_Serv ,Fech_Inicio, Horas_Realizadas de la tabla Registro
SELECT a.Matricula as Matricula, a.Nombre as Nombre, a.Carrera as Carrera, r.Cat_Serv as Tipo_servicio, e.Nombre_Empresa as Empresa, r.Fech_Inic as Fecha_inicio, r.H_Realizadas as Horas_realizadas
FROM Persona a
FULL OUTER JOIN Registro r ON a.Matricula = r.Matricula
FULL OUTER JOIN Empresa e ON r.ID_EMPRESA = e.ID_EMPRESA
WHERE a.rol = 1;

SELECT a.Matricula as Matricula, a.Nombre as Nombre, a.Carrera as Carrera, a.semestre as Semestre, r.Cat_Serv as Tipo_servicio, r.edo_serv as Estado,
e.Nombre_Empresa as Empresa, e.tel as TelefonoEmp, e.direccion as DireccionEmp,
r.Fech_Inic as Fecha_inicio, r.fech_fin as Fecha_fin, r.h_totales as Horas_totales, r.H_Realizadas as Horas_realizadas, r.h_faltantes as Horas_faltantes
FROM Persona a
FULL OUTER JOIN Registro r ON a.Matricula = r.Matricula
FULL OUTER JOIN Empresa e ON r.ID_EMPRESA = e.ID_EMPRESA
WHERE a.rol = 1;

SELECT a.Matricula as Matricula, a.Nombre as Nombre,  a.a_pat as ApellidoPat,  a.a_mat as ApellidoMat, a.Carrera as Carrera, a.semestre as Semestre, 
r.Cat_Serv as Tipo_servicio, r.edo_serv as Estado,e.Nombre_Empresa as Empresa, e.tel as TelefonoEmp, e.direccion as DireccionEmp,
r.Fech_Inic as Fecha_inicio, r.fech_fin as Fecha_fin, r.h_totales as Horas_totales, r.H_Realizadas as Horas_realizadas, r.h_faltantes as Horas_faltantes 
FROM Persona a 
FULL OUTER JOIN Registro r ON a.Matricula = r.Matricula 
FULL OUTER JOIN Empresa e ON r.ID_EMPRESA = e.ID_EMPRESA  
WHERE r.matricula = 14427690 and r.cat_serv = 'Practicas'

SELECT P.NOMBRE, R.ID_REGISTRO, R.EDO_SERV, R.ID_EMPRESA FROM REGISTRO R, PERSONA P
 WHERE R.MATRICULA = 14427690 AND R.CAT_SERV = 'Practicas'



select * from registro;

---------------------------TRIGGER PARA PONER EL ESTADO DE SERVICIO EN LA TABLA REGISTRO COMO ACTIVO POR DEFAULT--------------------
create or replace trigger REGISTRO$Edo_Serv
  before insert on registro  
  for each row
declare
  Edo_def varchar2(10):= 'Activo'; 
begin
  :new.Edo_Serv := Edo_def;
  :new.H_Realizadas := 0;
end REGISTRO$Edo_Serv;
--------------------------TRIGGER CALCULAR LAS HORAS FALTANTES EN LA TABLA DE REGISTRO----------------------------------------------
create or replace trigger REG$Act_hrs
before insert or update on Registro
for each row
begin
    if UPDATING('H_Realizadas') then
        :NEW.H_Faltantes := :NEW.H_Totales - :NEW.H_Realizadas;
        if :NEW.H_Faltantes = 0 then
            :NEW.EDO_Serv := 'COMPLETADO';
            :NEW.fech_fin := SYSDATE;
        end if;
    end if;
end REG$Act_hrs;
--------------------------TRIGGER QUE AL INGRESAR LAS HORAS QUE SE REALIZO LAS ACUMULA----------------------------------------------
create or replace trigger REG$Acum_HrsR
  Before update on registro  
  for each row
declare
  
begin
  :NEW.H_Realizadas := :OLD.H_Realizadas + :NEW.H_Realizadas;
end REG$Acum_HrsR;

-------------------------TRIGGER PARA PONER EN AUTOMATICO EL ID DE REGISTRO----------------------------------------------------

create or replace trigger AUTOINCREMENT_REG
  before insert on registro  
  for each row
declare
  max_id_registro number;
  act_id_registro number;
begin

  select max(id_registro) into act_id_registro from registro;
  if act_id_registro is not null then
    select max(id_registro) + 1 into max_id_registro from registro;
    :new.id_registro := max_id_registro;
    else
    :new.id_registro := 1;
    end if;
end AUTOINCREMENT_REG;

-------------------------TRIGGER PARA PONER EN AUTOMATICO EL ID DE EMPRESA----------------------------------------------------

create or replace trigger AUTOINCREMENT_EMPR before insert on empresa  
  for each row
declare
  max_id_empresa number;
  act_id_empresa number;
begin
 select max(id_empresa)into act_id_empresa from empresa;
  if act_id_empresa is not null then 
    select max(id_empresa) + 1 into max_id_empresa from empresa;
  :new.id_empresa := max_id_empresa;
  else
      :new.id_empresa := 1;
  end if;
end AUTOINCREMENT_EMPR;
------------------------------TRIGGER PARA PONER EN AUTOMATICO MATRICULA EN LA TABLA PERSONA------------------------------------------
create or replace trigger AUTOINCREMENT_PERS before insert on persona
       for each row
declare 
       max_mat_persona number;
       act_mat_persona number;
begin
  select max(matricula) into act_mat_persona from persona;
  if act_mat_persona is not null then
    select max(matricula) + 1 into max_mat_persona from persona;
    :new.matricula := max_mat_persona;
    else
      :new.matricula := 1;
    end if;
end AUTOINCREMENT_PERS;


select * from persona;
select * from registro;
select * from empresa;


UPDATE REGISTRO SET EDO_SERV='Activo'


alter table registro modify fech_fin date null;
alter table registro modify H_realizadas integer null;

UPDATE REGISTRO SET H_Realizadas = 100 WHERE ID_Registro = 2
