--DROP DATABASE IF EXISTS datamart; 
CREATE DATABASE datamart; 
use datamart

CREATE TABLE [dbo].[DIMENSION_CLIENTE](
	[id_cliente] [int] NOT NULL,
	[nombre_cliente] [varchar](50) NOT NULL,
	[apellido_cliente] [varchar](50) NOT NULL,
	[ciudad] [varchar](50) NOT NULL,
	[region] [varchar](50) NULL,
	[pais] [varchar](50) NOT NULL,
	[codigo_postal] [varchar](10) NOT NULL,
	[id_empleado_rep_ventas] [int] NOT NULL,
	[limite_credito] [money] NOT NULL,
	PRIMARY KEY(id_cliente));

CREATE TABLE [dbo].[DIMENSION_EMPLEADO](
	[id_empleado] [int] NOT NULL,
	[id_oficina] [int] NOT NULL,
	[id_jefe] [int] NULL,
	[nombre_empleado] [varchar](50) NOT NULL,
	[apellidos_empleado] [varchar](50) NOT NULL,
	[puesto] [varchar](50) NOT NULL,
	PRIMARY KEY (id_empleado));

CREATE TABLE [dbo].[DIMENSION_OFICINA](
	[id_oficina] [int] NOT NULL,
	[descripcion] [varchar](10) NOT NULL,
	[ciudad] [varchar](50) NOT NULL,
	[region] [varchar](50) NOT NULL,
	[pais] [varchar](50) NOT NULL,
	[codigo_postal] [varchar](10) NOT NULL,
	PRIMARY KEY (id_oficina));

CREATE TABLE [dbo].[DIMENSION_PAGO](
	[id_pago] [int] NOT NULL,
	[id_cliente] [int] NOT NULL,
	[forma_pago] [varchar](40) NOT NULL,
	[id_transaccion] [varchar](50) NOT NULL,
	[fecha_pago] [datetime] NOT NULL,
	[total_pago] [money] NOT NULL,
	PRIMARY KEY (id_pago));

CREATE TABLE [dbo].[DIMENSION_PRODUCTO](
	[id_producto] [int] NOT NULL,
	[codigo_producto] [varchar](15) NOT NULL,
	[nombre] [varchar](70) NOT NULL,
	[desc_categoria] [varchar](50) NOT NULL,
	[proveedor] [varchar](50) NOT NULL,
	[precio_venta] [money] NOT NULL,
	[precio_proveedor] [money] NOT NULL,
	PRIMARY KEY (id_producto));

CREATE TABLE [dbo].[DIMENSION_TIEMPO](
	[fecha] [int] NOT NULL,
	[dia_anio] [int] NOT NULL,
	[dia_mes] [int] NOT NULL,
	[dia_semana] [int] NOT NULL,
	[mes] [int] NOT NULL,
	[anio] [int] NOT NULL,
	PRIMARY KEY(fecha));

CREATE TABLE [dbo].[HECHO_VENTA](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[id_pedido] [int] NOT NULL,
	[id_detalle_pedido] [int] NOT NULL,
	[id_producto] [int] NOT NULL,
	[id_cliente] [int] NOT NULL,
	[fecha_pedido] [int] NOT NULL,
	[fecha_esperado] [int] NOT NULL,
	[fecha_entregado] [int] NULL,
	[id_empleado] [int] NOT NULL,
	[id_oficina] [int] NOT NULL,
	[id_pago] [int] NULL,
	[estado] [varchar](15) NOT NULL,
	[precio_unidad] [money] NOT NULL,
	[unidades] [int] NOT NULL,
	[total] [money] NOT NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (id_producto) references DIMENSION_PRODUCTO(id_producto),
	FOREIGN KEY (id_cliente) references DIMENSION_CLIENTE(id_cliente),
	FOREIGN KEY (id_empleado) references DIMENSION_EMPLEADO(id_empleado),
	FOREIGN KEY (id_oficina) references DIMENSION_OFICINA(id_oficina),
	FOREIGN KEY (id_pago) references DIMENSION_PAGO(id_pago));

insert into DIMENSION_TIEMPO
select * from staging_jardineria.dbo.Tiempo

insert into DIMENSION_CLIENTE(id_cliente, nombre_cliente, apellido_cliente, ciudad, region, pais, codigo_postal, id_empleado_rep_ventas, limite_credito)
select c.ID_cliente, c.nombre_cliente, c.apellido_cliente, c.ciudad, c.region, c.pais, c.codigo_postal, c.ID_empleado_rep_ventas, c.limite_credito
from staging_jardineria.dbo.cliente as c

insert into DIMENSION_EMPLEADO(id_empleado, id_oficina, id_jefe, nombre_empleado, apellidos_empleado, puesto)
select e.ID_empleado, e.ID_oficina, e.ID_jefe, e.nombre, concat(e.apellido1, ' ', e.apellido2) as apellidos_empleado, e.puesto
from staging_jardineria.dbo.empleado as e

insert into DIMENSION_OFICINA(id_oficina, descripcion, ciudad, region, pais, codigo_postal)
select o.ID_oficina, o.Descripcion, o.ciudad, o.region, o.pais, o.codigo_postal
from staging_jardineria.dbo.oficina as o

insert into DIMENSION_PAGO(id_pago, id_cliente, forma_pago, id_transaccion, fecha_pago, total_pago)
select p.ID_pago, p.ID_cliente, p.forma_pago, p.id_transaccion, p.fecha_pago, p.total
from staging_jardineria.dbo.pago as p

insert into DIMENSION_PRODUCTO(id_producto, codigo_producto, nombre, desc_categoria, proveedor, precio_venta, precio_proveedor)
select p.ID_producto, p.CodigoProducto, p.nombre, p.Desc_Categoria, p.proveedor, p.precio_venta, p.precio_proveedor
from staging_jardineria.dbo.producto as p

insert into HECHO_VENTA(id_pedido, id_detalle_pedido, id_producto, id_cliente, fecha_pedido, fecha_esperado, fecha_entregado, id_empleado, id_oficina, 
	id_pago, estado, precio_unidad, unidades, total)
select 
	ped.ID_pedido as id_pedido, 
	det.ID_detalle_pedido as id_detalle_pedido,
	det.ID_producto as id_producto,
	ped.ID_cliente as id_cliente,
	CAST(FORMAT(ped.fecha_pedido, 'yyyyMMdd') as int) as fecha_pedido,
	CAST(FORMAT(ped.fecha_esperada, 'yyyyMMdd') as int) as fecha_esperado,
	CAST(FORMAT(ped.fecha_entrega, 'yyyyMMdd') as int) as fecha_entregado,
	emp.ID_empleado as id_empleado,
	emp.ID_oficina as id_oficina,
	null as id_pago,
	ped.estado as estado,
	det.precio_unidad as precio_unidad,
	det.cantidad as unidades,
	det.cantidad * det.precio_unidad as total
from staging_jardineria.dbo.pedido as ped
join staging_jardineria.dbo.detalle_pedido as det on ped.ID_pedido = det.ID_pedido
join staging_jardineria.dbo.cliente as cli on ped.ID_cliente = cli.ID_cliente
join staging_jardineria.dbo.empleado as emp on cli.ID_empleado_rep_ventas = emp.ID_empleado