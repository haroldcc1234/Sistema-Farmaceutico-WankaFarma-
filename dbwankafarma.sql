-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 02-10-2024 a las 16:05:55
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `dbwankafarma`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ActualizarCompraEstado` (IN `pidcompra` INT, IN `pestado` VARCHAR(20))   BEGIN
		UPDATE compra SET
			Estado=pestado
		WHERE idCompra = pidcompra;
	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ActualizarProductoStock` (IN `pidProducto` INT, IN `pstock` DECIMAL(8,2))   BEGIN
		UPDATE producto SET
			Stock=pstock
		WHERE idProducto = pidproducto;
	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ActualizarVentaEstado` (IN `pidventa` INT, IN `pestado` VARCHAR(20))   BEGIN
		UPDATE ventas SET
			Estado=pestado
		WHERE idventa = pidventa;
	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `BuscarProductos` (IN `criterio` VARCHAR(30), IN `Prod` VARCHAR(20))   BEGIN
	IF criterio='Buscar' THEN
		SELECT p.idProducto,pr.Descripcion AS presentacion,p.Descripcion,p.Concentracion,p.Stock,p.Costo,p.Precio_Venta,p.FechaVencimiento,p.RegistroSanitario,l.Nombre as laboratorio,p.Estado
		
		FROM producto AS p INNER JOIN presentacion AS pr ON p.idPresentacion=pr.idPresentacion
        INNER JOIN laboratorio AS l ON p.idLaboratorio=l.idLaboratorio
		WHERE p.Descripcion LIKE CONCAT("%",Prod,"%");
        END IF;
	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ComprasPorFecha` (IN `criterio` VARCHAR(30), IN `fechaIni` DATE, IN `fechaFin` DATE)   BEGIN
		IF criterio = "Buscar" THEN
			SELECT c.idCompra,p.Nombre AS proveedor,c.Fecha,CONCAT(e.Nombres," ",e.Apellidos) AS empleado,tc.Descripcion AS tipocomprobante,c.Numero,
			c.Estado,c.Total  FROM compra AS c
			INNER JOIN proveedor AS p ON c.idProveedor=p.IdProveedor
			INNER JOIN empleado AS e ON c.idEmpleado=e.idEmpleado
            INNER JOIN tipocomprobante AS tc ON c.idTipoComprobante=tc.idTipoComprobante
			WHERE (c.Fecha>=fechaIni AND c.Fecha<=fechaFin)  ORDER BY c.idCompra DESC;
            END IF;
            END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultaProductosCat` (IN `criterio` VARCHAR(30), IN `Prod` VARCHAR(20))   BEGIN
	IF criterio='Buscar' THEN
		SELECT p.idProducto,pr.Descripcion AS presentacion,p.Descripcion,p.Concentracion,p.Stock,p.Costo,p.Precio_Venta,p.FechaVencimiento,p.RegistroSanitario,l.Nombre as laboratorio,p.Estado
		
		FROM producto AS p INNER JOIN presentacion AS pr ON p.idPresentacion=pr.idPresentacion
        INNER JOIN laboratorio AS l ON p.idLaboratorio=l.idLaboratorio
		WHERE pr.Descripcion LIKE CONCAT("%",Prod,"%");
        END IF;
	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DetalleCompraParametro` (IN `criterio` VARCHAR(20), IN `buscar` VARCHAR(20))   BEGIN
			IF criterio = "id" THEN
				SELECT dc.idCompra,p.idProducto,pr.Descripcion AS presentacion,p.Descripcion,p.Concentracion,dc.Cantidad,dc.Costo,dc.Importe  FROM detallecompra AS dc
				INNER JOIN producto AS p ON dc.idProducto=p.idProducto
                INNER JOIN presentacion AS pr ON p.idPresentacion=pr.idPresentacion
				WHERE dc.idCompra=buscar ORDER BY dc.idCompra;
			
			END IF; 
			
	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DetalleVentaParametro` (IN `criterio` VARCHAR(20), IN `buscar` VARCHAR(20))   BEGIN
			IF criterio = "id" THEN
				SELECT dv.IdVenta,p.idProducto,pr.Descripcion AS presentacion,p.Descripcion,p.Concentracion,dv.Cantidad,dv.Precio,dv.Importe  FROM detalleventa AS dv
				INNER JOIN producto AS p ON dv.idProducto=p.idProducto
                INNER JOIN presentacion AS pr ON p.idPresentacion=pr.idPresentacion
				WHERE dv.IdVenta=buscar ORDER BY dv.IdVenta;
			
			END IF; 
			
	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProductosPorParametro` (IN `pcriterio` VARCHAR(20), IN `pbusqueda` VARCHAR(30))   BEGIN
	IF pcriterio = "id" THEN
		SELECT p.idProducto,p.Descripcion,p.Concentracion,p.Stock,p.Costo,p.Precio_Venta,p.RegistroSanitario,p.FechaVencimiento,p.Estado,c.Descripcion AS presentacion
		FROM producto AS p INNER JOIN presentacion AS c ON p.idPresentacion = c.idPresentacion
		WHERE p.idProducto=pbusqueda AND p.Estado="Activo";
        END IF;
        
        END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UltimoIdCompra` ()  NO SQL BEGIN
		SELECT MAX(idCompra) AS id FROM compra;
	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UltimoIdVenta` ()  NO SQL BEGIN
		SELECT MAX(idVenta) AS id FROM ventas;
	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `VentasPorDetalle` (IN `criterio` VARCHAR(30), IN `fechaIni` DATE, IN `fechaFin` DATE)   BEGIN
		IF criterio = "consultar" THEN
			SELECT p.idProducto,p.Descripcion AS Producto,pr.Descripcion AS Presentacion,dv.Costo,dv.Precio,
			SUM(dv.Cantidad) AS Cantidad,SUM(dv.Importe) AS Total,
			SUM(TRUNCATE((Importe-(dv.Costo*dv.Cantidad)),2)) AS Ganancia FROM ventas AS v
			INNER JOIN detalleventa AS dv ON v.IdVenta=dv.IdVenta
			INNER JOIN producto AS p ON dv.idProducto=p.idProducto
			INNER JOIN presentacion AS pr ON p.idPresentacion=pr.idPresentacion
			WHERE (v.Fecha>=fechaIni AND v.Fecha<=fechaFin) AND v.Estado="EMITIDO" GROUP BY p.IdProducto
			ORDER BY v.IdVenta DESC;
		END IF;

	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `VentasPorFecha` (IN `criterio` VARCHAR(30), IN `fechaIni` DATE, IN `fechaFin` DATE)   BEGIN
		IF criterio = "Buscar" THEN
			SELECT v.IdVenta,CONCAT(c.Nombres, " ",c.Apellidos) AS cliente,v.Fecha,CONCAT(e.Nombres," ",e.Apellidos) AS empleado,td.Descripcion AS tipocomprobante,v.Serie,v.Numero,
			v.Estado,v.Total  FROM ventas AS v
			INNER JOIN tipocomprobante AS td ON v.idTipoComprobante=td.idTipoComprobante
			INNER JOIN cliente AS c ON v.idCliente=c.idCliente
			INNER JOIN empleado AS e ON v.idEmpleado=e.idEmpleado
			WHERE (v.Fecha>=fechaIni AND v.Fecha<=fechaFin)ORDER BY v.IdVenta DESC;
            
            ELSEIF criterio = "caja" THEN	
		   SELECT SUM(dv.Cantidad) AS Cantidad,p.Descripcion AS Producto,dv.Precio,
			SUM(dv.Importe) AS Total, SUM(TRUNCATE((Importe-(dv.Costo*dv.Cantidad)),2)) AS Ganancia,v.Fecha FROM ventas AS v
			INNER JOIN detalleventa AS dv ON v.IdVenta=dv.IdVenta
			INNER JOIN producto AS p ON dv.idProducto=p.idProducto
			INNER JOIN presentacion AS pr ON p.idPresentacion=pr.idPresentacion
			WHERE v.Fecha=fechaIni AND v.Estado="EMITIDO" GROUP BY p.idProducto
			ORDER BY v.IdVenta DESC;
            
           
            END IF;
            END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `idCliente` int(11) NOT NULL,
  `Nombres` varchar(35) NOT NULL,
  `Apellidos` varchar(35) NOT NULL,
  `Sexo` varchar(2) NOT NULL,
  `Dni` varchar(10) NOT NULL,
  `Telefono` varchar(15) NOT NULL,
  `Ruc` varchar(20) NOT NULL,
  `Email` varchar(35) NOT NULL,
  `Direccion` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `compra`
--

CREATE TABLE `compra` (
  `idCompra` int(11) NOT NULL,
  `Numero` varchar(15) NOT NULL,
  `Fecha` date NOT NULL,
  `TipoPago` varchar(30) NOT NULL,
  `SubTotal` decimal(8,2) NOT NULL,
  `Total` decimal(8,2) NOT NULL,
  `Igv` decimal(8,2) NOT NULL,
  `Estado` varchar(10) NOT NULL,
  `idProveedor` int(11) NOT NULL,
  `idEmpleado` int(11) NOT NULL,
  `idTipoComprobante` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `compra`
--

INSERT INTO `compra` (`idCompra`, `Numero`, `Fecha`, `TipoPago`, `SubTotal`, `Total`, `Igv`, `Estado`, `idProveedor`, `idEmpleado`, `idTipoComprobante`) VALUES
(1, 'C00001', '2020-08-03', '', 49.15, 58.00, 8.85, 'NORMAL', 1, 1, 2),
(2, 'C00002', '2020-08-03', '', 5.08, 6.00, 0.91, 'NORMAL', 1, 1, 2),
(3, 'C00003', '2020-08-04', '', 5.08, 6.00, 0.91, 'ANULADO', 1, 1, 2),
(4, 'C00004', '2020-08-04', '', 138.14, 163.00, 24.87, 'NORMAL', 1, 1, 2),
(5, 'C00005', '2020-08-04', '', 12.71, 15.00, 2.29, 'NORMAL', 1, 1, 1),
(6, 'C00006', '2020-08-04', '', 115.25, 136.00, 20.75, 'NORMAL', 1, 1, 1),
(7, 'C00007', '2020-08-04', '', 67.80, 80.00, 12.20, 'NORMAL', 1, 1, 1),
(8, 'C00008', '2020-08-04', '', 61.69, 72.80, 11.10, 'NORMAL', 2, 1, 2),
(9, 'C00009', '2020-08-06', '', 33.90, 40.00, 6.10, 'ANULADO', 2, 1, 2),
(10, 'C00010', '2020-08-06', '', 63.56, 75.00, 11.44, 'NORMAL', 1, 1, 1),
(11, '000000', '2020-08-11', '', 105.93, 125.00, 19.07, 'NORMAL', 2, 1, 2),
(12, '0000001', '2020-08-13', '', 144.07, 170.00, 25.93, 'ANULADO', 2, 1, 2),
(13, '0000001', '2020-08-15', '', 36.02, 42.50, 6.48, 'NORMAL', 2, 1, 1),
(14, '0000001', '2020-08-17', '', 141.95, 167.50, 25.55, 'NORMAL', 1, 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detallecompra`
--

CREATE TABLE `detallecompra` (
  `idCompra` int(11) NOT NULL,
  `idProducto` int(11) NOT NULL,
  `Cantidad` int(11) NOT NULL,
  `Costo` decimal(8,2) NOT NULL,
  `Importe` decimal(8,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `detallecompra`
--

INSERT INTO `detallecompra` (`idCompra`, `idProducto`, `Cantidad`, `Costo`, `Importe`) VALUES
(1, 3, 29, 2.00, 58.00),
(2, 1, 20, 0.30, 6.00),
(2, 3, 15, 1.50, 22.50),
(3, 4, 20, 0.30, 6.00),
(4, 2, 1, 13.00, 13.00),
(4, 3, 100, 1.50, 150.00),
(5, 3, 10, 1.50, 15.00),
(6, 1, 20, 0.30, 6.00),
(6, 2, 10, 13.00, 130.00),
(7, 2, 5, 13.00, 65.00),
(7, 3, 10, 1.50, 15.00),
(8, 2, 5, 13.00, 65.00),
(8, 1, 20, 0.30, 6.00),
(8, 4, 6, 0.30, 1.80),
(9, 6, 10, 4.00, 40.00),
(10, 6, 15, 4.00, 60.00),
(10, 3, 10, 1.50, 15.00),
(11, 6, 10, 4.00, 40.00),
(11, 7, 10, 8.50, 85.00),
(12, 7, 20, 8.50, 170.00),
(13, 7, 5, 8.50, 42.50),
(14, 6, 10, 4.00, 40.00),
(14, 7, 15, 8.50, 127.50);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalleventa`
--

CREATE TABLE `detalleventa` (
  `IdVenta` int(11) NOT NULL,
  `idProducto` int(11) NOT NULL,
  `Cantidad` int(11) NOT NULL,
  `Costo` decimal(8,2) NOT NULL,
  `Precio` decimal(8,2) NOT NULL,
  `Importe` decimal(8,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `detalleventa`
--

INSERT INTO `detalleventa` (`IdVenta`, `idProducto`, `Cantidad`, `Costo`, `Precio`, `Importe`) VALUES
(27, 3, 4, 1.50, 2.50, 10.00),
(28, 1, 4, 0.30, 0.50, 2.00),
(29, 1, 4, 0.30, 0.50, 2.00),
(30, 2, 25, 13.00, 16.00, 400.00),
(30, 4, 4, 0.30, 0.50, 2.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleado`
--

CREATE TABLE `empleado` (
  `idEmpleado` int(11) NOT NULL,
  `Nombres` varchar(35) NOT NULL,
  `Apellidos` varchar(35) NOT NULL,
  `Especialidad` varchar(30) NOT NULL,
  `Sexo` varchar(2) NOT NULL,
  `Dni` int(10) NOT NULL,
  `Email` varchar(30) NOT NULL,
  `Telefono` int(15) NOT NULL,
  `Direccion` varchar(35) NOT NULL,
  `HoraIngreso` varchar(15) NOT NULL,
  `HoraSalida` varchar(15) NOT NULL,
  `Sueldo` decimal(8,2) NOT NULL,
  `Estado` varchar(10) NOT NULL,
  `idUsuario` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `laboratorio`
--

CREATE TABLE `laboratorio` (
  `idLaboratorio` int(11) NOT NULL,
  `Nombre` varchar(35) NOT NULL,
  `Direccion` varchar(35) NOT NULL,
  `Telefono` int(15) NOT NULL,
  `Estado` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `presentacion`
--

CREATE TABLE `presentacion` (
  `idPresentacion` int(11) NOT NULL,
  `Descripcion` varchar(35) NOT NULL,
  `Estado` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `presentacion`
--

INSERT INTO `presentacion` (`idPresentacion`, `Descripcion`, `Estado`) VALUES
(1, 'Aerosol', 'Activo'),
(2, 'Capsula', 'Activo'),
(3, 'Colirio', 'Activo'),
(4, 'Concentración', 'Inactivo'),
(5, 'Crema', 'Activo'),
(6, 'Elixir', 'Activo'),
(7, 'Emulsion', 'Inactivo'),
(8, 'Enema', 'Activo'),
(9, 'Espuma', 'Activo'),
(10, 'Farmaco', 'Activo'),
(11, 'Gel', 'Activo'),
(12, 'Gragea', 'Activo'),
(13, 'Granulos', 'Activo'),
(14, 'Inyectable', 'Activo'),
(15, 'Jalea', 'Activo'),
(16, 'Jarabe', 'Activo'),
(17, 'Linimento', 'Activo'),
(18, 'Locion', 'Activo'),
(19, 'Medicamento', 'Activo'),
(20, 'Ovulo', 'Activo'),
(21, 'Pasta', 'Inactivo'),
(22, 'Polvo', 'Activo'),
(23, 'Pomada', 'Activo'),
(24, 'Solución', 'Activo'),
(25, 'Supositorio', 'Inactivo'),
(26, 'Suspensión', 'Activo'),
(27, 'Tableta', 'Activo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

CREATE TABLE `producto` (
  `idProducto` int(11) NOT NULL,
  `Descripcion` varchar(35) NOT NULL,
  `Concentracion` varchar(30) NOT NULL,
  `Stock` int(11) NOT NULL,
  `Costo` decimal(8,2) NOT NULL,
  `Precio_Venta` decimal(8,2) NOT NULL,
  `RegistroSanitario` varchar(20) NOT NULL,
  `FechaVencimiento` date NOT NULL,
  `Estado` varchar(10) NOT NULL,
  `idPresentacion` int(11) NOT NULL,
  `idLaboratorio` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`idProducto`, `Descripcion`, `Concentracion`, `Stock`, `Costo`, `Precio_Venta`, `RegistroSanitario`, `FechaVencimiento`, `Estado`, `idPresentacion`, `idLaboratorio`) VALUES
(1, 'Ibuprofeno', '500 mg', 100, 0.30, 0.50, 'EN01867', '2021-08-08', 'Activo', 27, 6),
(2, 'Hepabionta', '10mg /30ml', 100, 13.00, 16.00, 'EN06374', '2022-08-14', 'Activo', 14, 4),
(3, 'Apronax', '500 mg', 100, 1.50, 2.50, 'EN01596', '2021-08-08', 'Activo', 27, 5),
(4, 'Naproxeno', '400 mg', 100, 0.30, 0.50, 'EE035471', '2022-08-11', 'Activo', 3, 4),
(5, 'Tylenol', '15 mg / 20ml', 100, 3.20, 3.80, 'EE03459', '2021-08-29', 'Inactivo', 7, 6),
(6, 'Penicilina', '500 mg', 100, 4.00, 4.80, 'EN03449', '2021-08-05', 'Activo', 14, 3),
(7, 'Flexitol', '1 %', 100, 8.50, 9.80, 'EE01298', '2021-08-16', 'Activo', 16, 3),
(8, 'Apronax', ' 500 mg', 100, 0.50, 0.80, 'EE032145', '2021-08-13', 'Inactivo', 27, 4),
(9, 'Panadol', '400 mg', 100, 2.80, 3.20, 'EE06185', '2021-08-22', 'Activo', 27, 8);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedor`
--

CREATE TABLE `proveedor` (
  `IdProveedor` int(11) NOT NULL,
  `Nombre` varchar(35) NOT NULL,
  `Dni` varchar(11) NOT NULL,
  `Ruc` varchar(20) NOT NULL,
  `Direccion` varchar(35) NOT NULL,
  `Email` varchar(35) NOT NULL,
  `Telefono` varchar(20) NOT NULL,
  `Banco` varchar(35) NOT NULL,
  `Cuenta` varchar(35) NOT NULL,
  `Estado` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `proveedor`
--

INSERT INTO `proveedor` (`IdProveedor`, `Nombre`, `Dni`, `Ruc`, `Direccion`, `Email`, `Telefono`, `Banco`, `Cuenta`, `Estado`) VALUES
(1, 'JORGE RAUL CAMUS PILCO', '33425689', '10334256897', 'Jr.Amazonas', 'jorgeraul@hotmail.com', '987612453', 'BCP', '1032456759484', 'Activo'),
(2, 'ELIFARMA', '', '0933428595', 'Av. Heroes del cenepa 1520', '', '987412350', 'BCP', '0126544949944884', 'Activo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipocomprobante`
--

CREATE TABLE `tipocomprobante` (
  `idTipoComprobante` int(11) NOT NULL,
  `Descripcion` varchar(35) NOT NULL,
  `Estado` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipocomprobante`
--

INSERT INTO `tipocomprobante` (`idTipoComprobante`, `Descripcion`, `Estado`) VALUES
(1, 'Boleta', 'Activo'),
(2, 'Factura', 'Activo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `idUsuario` int(11) NOT NULL,
  `Nombres` varchar(35) NOT NULL,
  `Apellidos` varchar(35) NOT NULL,
  `Dni` int(11) NOT NULL,
  `Email` varchar(35) NOT NULL,
  `Usuario` varchar(30) NOT NULL,
  `Contraseña` varchar(30) NOT NULL,
  `TipoUsuario` varchar(20) NOT NULL,
  `Estado` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`idUsuario`, `Nombres`, `Apellidos`, `Dni`, `Email`, `Usuario`, `Contraseña`, `TipoUsuario`, `Estado`) VALUES
(2, 'Harold', 'Corilloclla Chaupin', 71629284, 'harcc@gmail.com', 'Harold1234', '123456', 'Administrador', 'Activo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas`
--

CREATE TABLE `ventas` (
  `IdVenta` int(11) NOT NULL,
  `Serie` varchar(10) NOT NULL,
  `Numero` varchar(20) NOT NULL,
  `Fecha` date NOT NULL,
  `VentaTotal` decimal(8,2) NOT NULL,
  `Descuento` decimal(8,2) NOT NULL,
  `SubTotal` decimal(8,2) NOT NULL,
  `Igv` decimal(8,2) NOT NULL,
  `Total` decimal(8,2) NOT NULL,
  `Estado` varchar(10) NOT NULL,
  `idCliente` int(11) NOT NULL,
  `idEmpleado` int(11) NOT NULL,
  `idTipoComprobante` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `ventas`
--

INSERT INTO `ventas` (`IdVenta`, `Serie`, `Numero`, `Fecha`, `VentaTotal`, `Descuento`, `SubTotal`, `Igv`, `Total`, `Estado`, `idCliente`, `idEmpleado`, `idTipoComprobante`) VALUES
(27, '001', 'C00027', '2024-09-30', 10.00, 0.00, 8.47, 1.52, 10.00, 'EMITIDO', 2, 1, 1),
(28, '001', 'C00028', '2024-10-01', 2.00, 0.00, 1.69, 0.30, 2.00, 'EMITIDO', 2, 1, 1),
(29, '001', 'C00029', '2024-10-01', 2.00, 0.00, 1.69, 0.30, 2.00, 'EMITIDO', 2, 1, 1),
(30, '001', 'C00030', '2024-10-01', 402.00, 0.00, 340.68, 61.32, 402.00, 'EMITIDO', 9, 1, 1);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`idCliente`);

--
-- Indices de la tabla `compra`
--
ALTER TABLE `compra`
  ADD PRIMARY KEY (`idCompra`),
  ADD KEY `idProveedor` (`idProveedor`),
  ADD KEY `idEmpleado` (`idEmpleado`),
  ADD KEY `idTipoComprobante` (`idTipoComprobante`);

--
-- Indices de la tabla `detallecompra`
--
ALTER TABLE `detallecompra`
  ADD KEY `idCompra` (`idCompra`),
  ADD KEY `idProducto` (`idProducto`);

--
-- Indices de la tabla `detalleventa`
--
ALTER TABLE `detalleventa`
  ADD KEY `IdVenta` (`IdVenta`),
  ADD KEY `idProducto` (`idProducto`);

--
-- Indices de la tabla `empleado`
--
ALTER TABLE `empleado`
  ADD PRIMARY KEY (`idEmpleado`),
  ADD KEY `idUsuario` (`idUsuario`);

--
-- Indices de la tabla `laboratorio`
--
ALTER TABLE `laboratorio`
  ADD PRIMARY KEY (`idLaboratorio`);

--
-- Indices de la tabla `presentacion`
--
ALTER TABLE `presentacion`
  ADD PRIMARY KEY (`idPresentacion`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`idProducto`),
  ADD KEY `idPresentacion` (`idPresentacion`),
  ADD KEY `idLaboratorio` (`idLaboratorio`);

--
-- Indices de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  ADD PRIMARY KEY (`IdProveedor`);

--
-- Indices de la tabla `tipocomprobante`
--
ALTER TABLE `tipocomprobante`
  ADD PRIMARY KEY (`idTipoComprobante`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`idUsuario`);

--
-- Indices de la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD PRIMARY KEY (`IdVenta`),
  ADD KEY `idCliente` (`idCliente`),
  ADD KEY `idEmpleado` (`idEmpleado`),
  ADD KEY `idTipoComprobante` (`idTipoComprobante`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `idCliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `compra`
--
ALTER TABLE `compra`
  MODIFY `idCompra` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `empleado`
--
ALTER TABLE `empleado`
  MODIFY `idEmpleado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `laboratorio`
--
ALTER TABLE `laboratorio`
  MODIFY `idLaboratorio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `presentacion`
--
ALTER TABLE `presentacion`
  MODIFY `idPresentacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `idProducto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  MODIFY `IdProveedor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `tipocomprobante`
--
ALTER TABLE `tipocomprobante`
  MODIFY `idTipoComprobante` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `idUsuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `ventas`
--
ALTER TABLE `ventas`
  MODIFY `IdVenta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `compra`
--
ALTER TABLE `compra`
  ADD CONSTRAINT `compra_ibfk_1` FOREIGN KEY (`idTipoComprobante`) REFERENCES `tipocomprobante` (`idTipoComprobante`),
  ADD CONSTRAINT `compra_ibfk_2` FOREIGN KEY (`idEmpleado`) REFERENCES `empleado` (`idEmpleado`),
  ADD CONSTRAINT `compra_ibfk_3` FOREIGN KEY (`idProveedor`) REFERENCES `proveedor` (`IdProveedor`);

--
-- Filtros para la tabla `detallecompra`
--
ALTER TABLE `detallecompra`
  ADD CONSTRAINT `detallecompra_ibfk_1` FOREIGN KEY (`idProducto`) REFERENCES `producto` (`idProducto`),
  ADD CONSTRAINT `detallecompra_ibfk_2` FOREIGN KEY (`idCompra`) REFERENCES `compra` (`idCompra`);

--
-- Filtros para la tabla `detalleventa`
--
ALTER TABLE `detalleventa`
  ADD CONSTRAINT `detalleventa_ibfk_1` FOREIGN KEY (`idProducto`) REFERENCES `producto` (`idProducto`),
  ADD CONSTRAINT `detalleventa_ibfk_2` FOREIGN KEY (`IdVenta`) REFERENCES `ventas` (`IdVenta`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `producto`
--
ALTER TABLE `producto`
  ADD CONSTRAINT `producto_ibfk_1` FOREIGN KEY (`idLaboratorio`) REFERENCES `laboratorio` (`idLaboratorio`),
  ADD CONSTRAINT `producto_ibfk_2` FOREIGN KEY (`idPresentacion`) REFERENCES `presentacion` (`idPresentacion`);

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`idUsuario`) REFERENCES `empleado` (`idUsuario`);

--
-- Filtros para la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD CONSTRAINT `ventas_ibfk_1` FOREIGN KEY (`idTipoComprobante`) REFERENCES `tipocomprobante` (`idTipoComprobante`),
  ADD CONSTRAINT `ventas_ibfk_2` FOREIGN KEY (`idCliente`) REFERENCES `cliente` (`idCliente`),
  ADD CONSTRAINT `ventas_ibfk_3` FOREIGN KEY (`idEmpleado`) REFERENCES `empleado` (`idEmpleado`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
