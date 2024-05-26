--DROP DATABASE IF EXISTS staging_jardineria; 
CREATE DATABASE staging_jardineria; 
USE staging_jardineria;


CREATE TABLE oficina (
  ID_oficina int NOT NULL, 
  Descripcion VARCHAR(10) NOT NULL,
  ciudad VARCHAR(30) NOT NULL,
  pais VARCHAR(50) NOT NULL,
  region VARCHAR(50) DEFAULT NULL,
  codigo_postal VARCHAR(10) NOT NULL,
  PRIMARY KEY (ID_oficina)
);

CREATE TABLE empleado (
  ID_empleado INT NOT NULL,
  nombre VARCHAR(50) NOT NULL,
  apellido1 VARCHAR(50) NOT NULL,
  apellido2 VARCHAR(50) DEFAULT NULL,
  ID_oficina int NOT NULL,
  ID_jefe INTEGER DEFAULT NULL,
  puesto VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY ( ID_empleado),
  FOREIGN KEY ( ID_oficina) REFERENCES oficina ( ID_oficina),
  FOREIGN KEY ( ID_jefe) REFERENCES empleado ( ID_empleado)
);

CREATE TABLE Categoria_producto (
  Id_Categoria int NOT NULL,
  Desc_Categoria VARCHAR(50) NOT NULL,
  PRIMARY KEY ( Id_Categoria)
);

CREATE TABLE cliente (
  ID_cliente INTEGER NOT NULL,
  nombre_cliente VARCHAR(30) DEFAULT NULL,
  apellido_cliente VARCHAR(30) DEFAULT NULL,
  ciudad VARCHAR(50) NOT NULL,
  region VARCHAR(50) DEFAULT NULL,
  pais VARCHAR(50) DEFAULT NULL,
  codigo_postal VARCHAR(10) DEFAULT NULL,
  ID_empleado_rep_ventas INTEGER DEFAULT NULL,
  limite_credito NUMERIC(15,2) DEFAULT NULL,
  PRIMARY KEY ( ID_cliente),
  FOREIGN KEY ( ID_empleado_rep_ventas) REFERENCES empleado ( ID_empleado)
);

CREATE TABLE pedido (
  ID_pedido int NOT NULL,
  fecha_pedido date NOT NULL,
  fecha_esperada date NOT NULL,
  fecha_entrega date DEFAULT NULL,
  estado VARCHAR(15) NOT NULL,
  ID_cliente INTEGER NOT NULL,
  PRIMARY KEY ( ID_pedido),
  FOREIGN KEY ( ID_cliente) REFERENCES cliente ( ID_cliente)
);

CREATE TABLE producto (
  ID_producto int NOT NULL,
  CodigoProducto VARCHAR(15) NOT NULL,
  nombre VARCHAR(70) NOT NULL,
  Desc_Categoria varchar(50) NOT NULL,
  proveedor VARCHAR(50) DEFAULT NULL,
  precio_venta NUMERIC(15,2) NOT NULL,
  precio_proveedor NUMERIC(15,2) DEFAULT NULL,
  PRIMARY KEY ( ID_producto),
);

CREATE TABLE detalle_pedido (
  ID_detalle_pedido int NOT NULL,
  ID_pedido INTEGER NOT NULL,
  ID_producto INTEGER NOT NULL,
  cantidad INTEGER NOT NULL,
  precio_unidad NUMERIC(15,2) NOT NULL,
  PRIMARY KEY ( ID_detalle_pedido),
  FOREIGN KEY ( ID_pedido) REFERENCES pedido ( ID_pedido),
  FOREIGN KEY ( ID_producto) REFERENCES producto ( ID_producto)
);

CREATE TABLE pago (
  ID_pago int NOT NULL,
  ID_cliente INTEGER NOT NULL,
  forma_pago VARCHAR(40) NOT NULL,
  id_transaccion VARCHAR(50) NOT NULL,
  fecha_pago date NOT NULL,
  total NUMERIC(15,2) NOT NULL,
  PRIMARY KEY ( ID_pago),
  FOREIGN KEY ( ID_cliente) REFERENCES cliente ( ID_cliente)
);

CREATE TABLE Tiempo(
	fecha INTEGER NOT NULL,
	dia_anio INTEGER NOT NULL,
	dia_mes INTEGER NOT NULL,
	dia_semana INTEGER NOT NULL,
	mes INTEGER NOT NULL,
	anio INTEGER NOT NULL,
    PRIMARY KEY (fecha)
);

insert into staging_jardineria.dbo.Categoria_producto( Id_Categoria, Desc_Categoria)
select Id_Categoria, Desc_Categoria
from jardineria.dbo.Categoria_producto

insert into staging_jardineria.dbo.oficina( ID_oficina, Descripcion, ciudad, pais, region, codigo_postal)
select ID_oficina, Descripcion, ciudad, pais, region, codigo_postal
from jardineria.dbo.oficina

insert into staging_jardineria.dbo.empleado( ID_empleado, nombre, apellido1, apellido2, ID_oficina, ID_jefe, puesto)
select ID_empleado, nombre, apellido1, apellido2, ID_oficina, ID_jefe, puesto
from jardineria.dbo.empleado

insert into staging_jardineria.dbo.cliente( ID_cliente, nombre_cliente, apellido_cliente, ciudad, region, pais, codigo_postal, ID_empleado_rep_ventas, limite_credito)
select ID_cliente, nombre_contacto as nombre_cliente, apellido_contacto as apellido_cliente, ciudad, region, pais, codigo_postal, ID_empleado_rep_ventas, limite_credito
from jardineria.dbo.cliente

insert into staging_jardineria.dbo.producto( ID_producto, CodigoProducto, nombre, Desc_Categoria, proveedor, precio_venta, precio_proveedor)
select ID_producto, CodigoProducto, nombre, (select cp.Desc_Categoria from jardineria.dbo.Categoria_producto as cp where cp.Id_Categoria = p.Categoria) as Desc_Categoria, proveedor, precio_venta, precio_proveedor
from jardineria.dbo.producto as p

insert into staging_jardineria.dbo.pedido( ID_pedido, fecha_pedido, fecha_esperada, fecha_entrega, estado, ID_cliente)
select ID_pedido, fecha_pedido, fecha_esperada, fecha_entrega, estado, ID_cliente
from jardineria.dbo.pedido

insert into staging_jardineria.dbo.detalle_pedido( ID_detalle_pedido, ID_pedido, ID_producto, cantidad, precio_unidad)
select ID_detalle_pedido, ID_pedido, ID_producto, cantidad, precio_unidad
from jardineria.dbo.detalle_pedido

insert into staging_jardineria.dbo.pago( ID_pago, ID_cliente, forma_pago, id_transaccion, fecha_pago, total)
select ID_pago, ID_cliente, forma_pago, id_transaccion, fecha_pago, total
from jardineria.dbo.pago

create table #temp_fechas(fecha int, dia_anio int, dia_mes int, dia_semana int, mes int, anio int)

insert into #temp_fechas(fecha, dia_anio, dia_mes, dia_semana, mes, anio)
select CAST(FORMAT(p.fecha_pedido, 'yyyyMMdd') AS INT) as fecha, DATEPART(DAYOFYEAR, p.fecha_pedido) as dia_anio, DATEPART(DAY, p.fecha_pedido) as dia_mes, DATEPART(WEEKDAY, p.fecha_pedido) as dia_semana, DATEPART(MONTH, p.fecha_pedido) as mes, DATEPART(YEAR, p.fecha_pedido) anio
from staging_jardineria.dbo.pedido as p

insert into #temp_fechas(fecha, dia_anio, dia_mes, dia_semana, mes, anio)
select CAST(FORMAT(p.fecha_pedido, 'yyyyMMdd') AS INT) as fecha, DATEPART(DAYOFYEAR, p.fecha_pedido) as dia_anio, DATEPART(DAY, p.fecha_pedido) as dia_mes, DATEPART(WEEKDAY, p.fecha_pedido) as dia_semana, DATEPART(MONTH, p.fecha_pedido) as mes, DATEPART(YEAR, p.fecha_pedido) anio
from staging_jardineria.dbo.pedido as p

insert into #temp_fechas(fecha, dia_anio, dia_mes, dia_semana, mes, anio)
select CAST(FORMAT(p.fecha_entrega, 'yyyyMMdd') AS INT) as fecha, DATEPART(DAYOFYEAR, p.fecha_entrega) as dia_anio, DATEPART(DAY, p.fecha_entrega) as dia_mes, DATEPART(WEEKDAY, p.fecha_entrega) as dia_semana, DATEPART(MONTH, p.fecha_entrega) as mes, DATEPART(YEAR, p.fecha_entrega) anio
from staging_jardineria.dbo.pedido as p
where p.fecha_entrega <> null

insert into #temp_fechas(fecha, dia_anio, dia_mes, dia_semana, mes, anio)
select CAST(FORMAT(p.fecha_esperada, 'yyyyMMdd') AS INT) as fecha, DATEPART(DAYOFYEAR, p.fecha_esperada) as dia_anio, DATEPART(DAY, p.fecha_esperada) as dia_mes, DATEPART(WEEKDAY, p.fecha_esperada) as dia_semana, DATEPART(MONTH, p.fecha_esperada) as mes, DATEPART(YEAR, p.fecha_esperada) anio
from staging_jardineria.dbo.pedido as p
where p.fecha_esperada <> null

insert into #temp_fechas(fecha, dia_anio, dia_mes, dia_semana, mes, anio)
select CAST(FORMAT(p.fecha_pago, 'yyyyMMdd') AS INT) as fecha, DATEPART(DAYOFYEAR, p.fecha_pago) as dia_anio, DATEPART(DAY, p.fecha_pago) as dia_mes, DATEPART(WEEKDAY, p.fecha_pago) as dia_semana, DATEPART(MONTH, p.fecha_pago) as mes, DATEPART(YEAR, p.fecha_pago) anio
from staging_jardineria.dbo.pago as p

insert into staging_jardineria.dbo.tiempo(fecha, dia_anio, dia_mes, dia_semana, mes, anio)
select distinct tf.fecha, tf.dia_anio, tf.dia_mes, tf.dia_semana, tf.mes, tf.anio
from #temp_fechas as tf

drop table #temp_fechas