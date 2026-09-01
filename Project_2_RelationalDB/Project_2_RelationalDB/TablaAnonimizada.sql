USE [PortfolioProject2]
GO

/****** Objeto: Table [dbo].[TablaAnonimizada] Fecha de script: 1/9/2026 09:53:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TablaAnonimizada](
	[Estudiante_ID] [bigint] NULL,
	[Nombre_Anonimo] [varchar](41) NULL,
	[edad] [tinyint] NOT NULL,
	[sexo] [nvarchar](50) NOT NULL,
	[carrera] [nvarchar](50) NOT NULL,
	[perfil_solicitado] [nvarchar](50) NOT NULL,
	[apoyo_socioeconómico] [nvarchar](50) NOT NULL,
	[beca_adicional] [nvarchar](50) NULL,
	[plaza_actual] [nvarchar](50) NOT NULL,
	[profesor_supervisor] [nvarchar](100) NULL,
	[plaza_asignada] [nvarchar](100) NULL,
	[status_entrevista] [nvarchar](50) NOT NULL,
	[aprobado_T2223_2] [nvarchar](50) NOT NULL,
	[aprobado_T2223_3] [nvarchar](50) NOT NULL,
	[validar_documentos] [nvarchar](50) NOT NULL
) ON [PRIMARY]
GO


