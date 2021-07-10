



-- Muchas gracias por la oportunidad para participar en su selección
-- La entrevista fue una grata experiencia. 
-- Saludos. 


--------------TABLAS------------

 CREATE TABLE Personajes(
    Id_Personaje INT PRIMARY KEY IDENTITY (1, 1),
    Nombre_Real VARCHAR (100) NOT NULL,
    Nombre_Personaje VARCHAR (100) NOT NULL,
    Fecha_Creacion DATE,
    Fecha_Muerte DATE
);

 CREATE TABLE SuperPoder(
    Id_Poder INT PRIMARY KEY IDENTITY (1, 1),
	Nombre_Poder VARCHAR (50) NOT NULL,
);

 CREATE TABLE Personajes_Poder(
    IdPP INT PRIMARY KEY IDENTITY (1, 1),
    Id_Poder INT NOT NULL,
    Id_Personaje INT NOT NULL,
    FOREIGN KEY (Id_Poder) REFERENCES SuperPoder (Id_Poder),
	FOREIGN KEY (Id_Personaje) REFERENCES Personajes (Id_Personaje)
);

--------------STORED PROCEDURES 1-----------
CREATE PROCEDURE SP_Personajes_Accion
@NOMBREREAL varchar(50),
@NOMBREPERSONAJE  varchar(50),
@PODERES VARCHAR (500),
@FechaCreacion date,
@FechaMuerte date,
@ACCION int
AS
BEGIN

	--ACCION = 1 -> INSERTAR PERSONAJE
	--ACCION = 2 -> ACTUALIZAR PERSONAJE
	--ACCION = 3 -> ELIMINAR PERSONAJE
      
DECLARE @ID_PODER INT;
DECLARE @VALORPODER varchar(50);
DECLARE @ID_PERSONAJE INT;
SELECT @ID_PERSONAJE = Id_Personaje FROM Personajes  WHERE Nombre_Personaje = @NOMBREPERSONAJE

	--INSERTAR PERSONAJE
    IF(@Accion = 1)
		  BEGIN

		   INSERT INTO Personajes VALUES( @NOMBREREAL, @NOMBREPERSONAJE, @FechaCreacion, @FechaMuerte)

		   SELECT @ID_PERSONAJE = Id_Personaje FROM Personajes  WHERE Nombre_Personaje = @NOMBREPERSONAJE

		   SET @PODERES =  REPLACE(@PODERES, ' ', ''); 

	       INSERT INTO SuperPoder 
				   SELECT value FROM STRING_SPLIT(@PODERES,',') WHERE NOT EXISTS (SELECT Nombre_Poder FROM SuperPoder s where s.Nombre_Poder = value)
		   
		   DECLARE @TablaPoderes as Table
			  (ID INT, NOMBREPODER VARCHAR(50))

		   INSERT INTO @TablaPoderes 
			  SELECT ID_PODER, NOMBRE_PODER FROM SuperPoder
			     WHERE NOMBRE_PODER IN (SELECT value FROM STRING_SPLIT(@PODERES,',')) 

		   INSERT INTO Personajes_Poder
			  SELECT  A.ID , @ID_PERSONAJE FROM @TablaPoderes AS A
 
		  END

	--ACTUALIZAR PERSONAJE
	  IF (@Accion = 2)
	      BEGIN
	        UPDATE Personajes SET 
	          Nombre_Real = @NombreReal, 
		      Nombre_Personaje = @NombrePersonaje, 
		      Fecha_Creacion = @FechaCreacion, 
		      Fecha_Muerte = @FechaMuerte
	            WHERE Nombre_Personaje = @NombrePersonaje

			    INSERT INTO SuperPoder 
				   SELECT value FROM STRING_SPLIT(@PODERES,',') WHERE NOT EXISTS (SELECT Nombre_Poder FROM SuperPoder s where s.Nombre_Poder = value)
	   
				DECLARE @TablaPoderesUpd as Table
				   (ID INT, NOMBREPODER VARCHAR(50))

				INSERT INTO @TablaPoderesUpd 
				  SELECT ID_PODER, NOMBRE_PODER FROM SuperPoder
					 WHERE NOMBRE_PODER IN (SELECT value FROM STRING_SPLIT(@PODERES,',')) 

				DELETE FROM Personajes_Poder WHERE Id_Personaje = @ID_PERSONAJE
				INSERT INTO Personajes_Poder
				  SELECT  A.ID , @ID_PERSONAJE FROM @TablaPoderesUpd AS A
		 
	   END

	-- ELIMINAR REGISTRO
	   IF(@Accion = 3)
		  BEGIN
		     DELETE FROM Personajes_Poder WHERE Id_Personaje = @ID_PERSONAJE
		     DELETE FROM Personajes WHERE Nombre_Personaje = @NombrePersonaje
	   END
END
 
--------------STORED PROCEDURES 2-----------
CREATE PROCEDURE SP_Personajes_Coexistentes
@AÑO varchar(10)
 AS
BEGIN
  SELECT * FROM Personajes WHERE YEAR(Fecha_Muerte) > @AÑO
END
 
--------------STORED PROCEDURES 3-----------
CREATE PROCEDURE SP_Personajes_BuscarXPoderes
@PODERES varchar(20)
 AS
BEGIN
 SET @PODERES = REPLACE(@PODERES, ' ', ''); 
  SELECT DISTINCT P.Nombre_Personaje, P.Nombre_Real, P.Fecha_Creacion, P.Fecha_Muerte  FROM Personajes_Poder PP
    INNER JOIN Personajes P ON P.Id_Personaje = PP.Id_Personaje
	INNER JOIN SuperPoder SUPP ON SUPP.Id_Poder = PP.Id_Poder
	WHERE SUPP.Nombre_Poder IN  (SELECT value FROM STRING_SPLIT('CRONOQUINESIS,TELEKINESIS',','))  
END


-------EXECUCIÓN DE CÓDIGO------
   --- SP1 --
   
	exec SP_Personajes_Accion
	@NombreReal = 'Tony Stark',
	@NombrePersonaje ='Iron-man',
	@Poderes ='SUPER FUERZA, INTELECTO, VUELO SUPERSÓNICO',
	@FechaCreacion = '1970-05-29',
	@FechaMuerte = '2023-10-17',
	@Accion = '1'

	exec SP_Personajes_Accion
	@NombreReal = 'Stphen Vincent',
	@NombrePersonaje ='Doctor Strange',
	@Poderes ='MANIPULACIÓN DE MAGIA, TELETRANSPORTACIÓN, CRONOQUINESIS',
	@FechaCreacion = '1930-01-01',
	@FechaMuerte = '2072-10-17',
	@Accion = '1'

	exec SP_Personajes_Accion
	@NombreReal = 'Peter Parker',
	@NombrePersonaje ='Spider-man',
	@Poderes ='TELARAÑA, SUPER INSTINTO,SUPER FUERZA',
	@FechaCreacion = '1962-08-10',
	@FechaMuerte = '2061-01-01',
	@Accion = '1'

	exec SP_Personajes_Accion
	@NombreReal = 'Steven Grant',
	@NombrePersonaje ='Capitán America',
	@Poderes ='VELOCIDAD, AGILIDAD, SENTIDOS',
	@FechaCreacion = '1918-07-04',
	@FechaMuerte = '2070-01-01',
	@Accion = '1'

	exec SP_Personajes_Accion
	@NombreReal = 'Wanda Maximoff',
	@NombrePersonaje ='Bruja Escarlata',
	@Poderes ='MAGIA DEL CAOS, TELEKINESIS',
	@FechaCreacion = '1989-01-01',
	@FechaMuerte = '2080-01-01',
	@Accion = '1'

   --- SP2 --
exec SP_Personajes_Coexistentes 
@año = '2010'

   --- SP3 --
exec SP_Personajes_BuscarXPoderes 
@PODERES = 'CRONOQUINESIS,TELEKINESIS'