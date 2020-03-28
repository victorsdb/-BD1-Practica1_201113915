CREATE USER pract1_ejercicio1 
    IDENTIFIED BY 107990
        DEFAULT TABLESPACE users;
    
GRANT ALL PRIVILEGES 
    TO pract1_ejercicio1;

GRANT EXECUTE ANY PROCEDURE 
        TO pract1_ejercicio1;

CREATE TABLE Persona (
    Id_Persona  INTEGER     NOT NULL,
    Nombre      VARCHAR(50) NOT NULL,
    Direccion   VARCHAR(50) NOT NULL,
    Telefono    VARCHAR(20) NOT NULL,
    
    CONSTRAINT PK_Persona 
        PRIMARY KEY (Id_Persona)
);

CREATE TABLE Jinete(
    Persona             INTEGER     NOT NULL,
    Peso                FLOAT(2)    NOT NULL,
    Fecha_Ultimo_Peso   DATE        NOT NULL,

    CONSTRAINT PK_Jinete
        PRIMARY KEY (Persona),

    CONSTRAINT FK1_Jinete
        FOREIGN KEY (Persona)
            REFERENCES Persona(Id_Persona)
                ON DELETE CASCADE

);

CREATE TABLE Establo(
    Id_Establo  INTEGER     NOT NULL,
    Nombre      VARCHAR(50) NOT NULL,
    Telefono    VARCHAR(20) NOT NULL,
    Contacto    INTEGER     NOT NULL,
    
    CONSTRAINT PK_Establo
        PRIMARY KEY (Id_Establo),
    
    CONSTRAINT FK1_Establo
        FOREIGN KEY (Contacto)
            REFERENCES Persona(Id_Persona)
                ON DELETE CASCADE
);

CREATE TABLE Entrenador (
    Persona         INTEGER NOT NULL,
    Salario         INTEGER NOT NULL,
    Establo         INTEGER NOT NULL,

    CONSTRAINT PK_Entrenador
        PRIMARY KEY (Persona),

    CONSTRAINT FK1_Entrenador
        FOREIGN KEY (Persona)
            REFERENCES Persona(Id_Persona)
                ON DELETE CASCADE,
    
    CONSTRAINT FK2_Entrenador
        FOREIGN KEY (Establo)
            REFERENCES Establo(Id_Establo)
                ON DELETE CASCADE

);

CREATE TABLE Tipo_Caballo(
    Id_Tipo_Caballo INTEGER     NOT NULL,
    Tipo_Caballo    VARCHAR(50) NOT NULL,

    CONSTRAINT PK_Tipo_Caballo
        PRIMARY KEY (Id_Tipo_Caballo)
);

CREATE TABLE Genero(
    Id_Genero   INTEGER     NOT NULL,
    Genero      VARCHAR(50) NOT NULL,

    CONSTRAINT PK_Genero
        PRIMARY KEY (Id_Genero)
);

CREATE TABLE Caballo(
    Registro    INTEGER     NOT NULL,
    Nombre      VARCHAR(50) NOT NULL,
    Tipo        INTEGER     NOT NULL,
    Genero      INTEGER     NOT NULL,
    Entrenador  INTEGER     NOT NULL,

    CONSTRAINT PK_Caballo
        PRIMARY KEY (Registro),
    
    CONSTRAINT FK1_Caballo
        FOREIGN KEY (Tipo)
            REFERENCES Tipo_Caballo(Id_Tipo_Caballo)
                ON DELETE CASCADE,
    
    CONSTRAINT FK2_Caballo
        FOREIGN KEY (Genero)
            REFERENCES Genero(Id_Genero)
                ON DELETE CASCADE,

    CONSTRAINT FK3_Caballo
        FOREIGN KEY (Entrenador)
            REFERENCES Entrenador(Persona)
                ON DELETE CASCADE

);

CREATE TABLE Propietario_Persona (
    Caballo         INTEGER     NOT NULL,
    Persona         INTEGER     NOT NULL,
    Porcentaje      FLOAT(2)    NOT NULL,
    Fecha_Compra    DATE        NOT NULL,
    Precio          FLOAT(2)    NOT NULL,

    CONSTRAINT PK_Propietario_Persona
        PRIMARY KEY (Caballo, Persona),

    CONSTRAINT FK1_Propietario_Persona
        FOREIGN KEY (Caballo)
            REFERENCES Caballo(Registro)
                ON DELETE CASCADE,

    CONSTRAINT FK2_Propietario_Persona
        FOREIGN KEY (Persona)
            REFERENCES Persona(Id_Persona)
                ON DELETE CASCADE

);

CREATE TABLE Propietario_Establo (
    Caballo         INTEGER     NOT NULL,
    Establo         INTEGER     NOT NULL,
    Porcentaje      FLOAT(2)    NOT NULL,
    Fecha_Compra    DATE        NOT NULL,
    Precio          FLOAT(2)    NOT NULL,

    CONSTRAINT PK_Propietario_Establo
        PRIMARY KEY (Caballo, Establo),

    CONSTRAINT FK1_Propietario_Establo
        FOREIGN KEY (Caballo)
            REFERENCES Caballo(Registro)
                ON DELETE CASCADE,

    CONSTRAINT FK2_Propietario_Establo
        FOREIGN KEY (Establo)
            REFERENCES Establo(Id_Establo)
                ON DELETE CASCADE

);

CREATE TABLE Pista(
    Id_Pista    INTEGER     NOT NULL,
    Nombre      VARCHAR(50) NOT NULL,
    Direccion   VARCHAR(50) NOT NULL,

    CONSTRAINT PK_Pista
        PRIMARY KEY (Id_Pista)
);

CREATE TABLE Carrera(
    Id_Carrera  INTEGER NOT NULL,
    Fecha       DATE    NOT NULL,
    Cartera     FLOAT   NOT NULL,
    Pista       INTEGER NOT NULL,

    CONSTRAINT PK_Carrera
        PRIMARY KEY (Pista, Id_Carrera),
    
    CONSTRAINT FK1_Carrera
        FOREIGN KEY (Pista)
            REFERENCES Pista(Id_Pista)
                ON DELETE CASCADE, 
    
    CONSTRAINT Validar_Carrera
        CHECK (Id_Carrera BETWEEN 1 AND 10)

);

CREATE TABLE Entrada(

    Pista       INTEGER NOT NULL,
    Id_Carrera  INTEGER NOT NULL,
    Caballo     INTEGER NOT NULL,
    Jinete      INTEGER NOT NULL,
    Puerta      INTEGER NOT NULL,
    Puesto      INTEGER NULL,
    
    CONSTRAINT PK_Detalle_Entrada
        PRIMARY KEY (Pista, Id_Carrera, Caballo, Jinete, Puerta),

    CONSTRAINT FK1_Entrada
        FOREIGN KEY (Pista, Id_Carrera)
            REFERENCES Carrera(Pista, Id_Carrera) 
                ON DELETE CASCADE,

    CONSTRAINT FK2_Detalle_Entrada
        FOREIGN KEY (Caballo)
            REFERENCES Caballo(Registro) 
                ON DELETE CASCADE,

    CONSTRAINT FK3_Detalle_Entrada
        FOREIGN KEY (Jinete)
            REFERENCES Jinete(Persona) 
                ON DELETE CASCADE
            
);

CREATE OR REPLACE TRIGGER Porcentaje_Persona
    BEFORE INSERT OR UPDATE 
        ON Propietario_Persona
            FOR EACH ROW
DECLARE
    PORC_PERSONA FLOAT(2):=0.0;
    PORC_ESTABLO FLOAT(2):=0.0;
BEGIN

    SELECT SUM(Porcentaje) 
        INTO PORC_ESTABLO  
            FROM Propietario_Establo
                WHERE Propietario_Establo.Caballo = :new.Caballo
                    GROUP BY Propietario_Establo.Caballo;

    SELECT SUM(Porcentaje) 
        INTO PORC_PERSONA 
            FROM Propietario_Persona
                WHERE Propietario_Persona.Caballo = :new.Caballo  AND Propietario_Persona.Persona <> :new.Persona
                    GROUP BY Propietario_Persona.Caballo;
                            
    IF :new.Porcentaje > (100 - PORC_ESTABLO - PORC_PERSONA) THEN 
        raise_application_error(2000, 'Excede el 100% de Propiedad de un caballo');     
    END IF;
END;

CREATE OR REPLACE TRIGGER Porcentaje_Establo
    BEFORE INSERT OR UPDATE 
        ON Propietario_Establo
            FOR EACH ROW
DECLARE
    PORC_PERSONA FLOAT(2):=0.0;
    PORC_ESTABLO FLOAT(2):=0.0;
BEGIN
    
    SELECT SUM(Porcentaje) 
        INTO PORC_ESTABLO  
            FROM Propietario_Establo
                WHERE Propietario_Establo.Caballo = :new.Caballo AND Propietario_Establo.Establo <> :new.Establo
                    GROUP BY Propietario_Establo.Caballo;

    SELECT SUM(Porcentaje) 
        INTO PORC_PERSONA 
            FROM Propietario_Persona
                WHERE Propietario_Persona.Caballo = :new.Caballo
                    GROUP BY Propietario_Persona.Caballo;
    
    IF :new.Porcentaje > :old.Porcentaje AND :new.Porcentaje > (100 - PORC_ESTABLO - PORC_PERSONA) THEN
        raise_application_error(2000, 'Excede el 100% de Propiedad de un caballo');     
    END IF;

END;