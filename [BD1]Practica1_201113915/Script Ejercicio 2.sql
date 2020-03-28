CREATE USER pract1_ejercicio2 IDENTIFIED BY 107990
    DEFAULT TABLESPACE users;
    
GRANT ALL PRIVILEGES TO pract1_ejercicio2;

GRANT EXECUTE ANY PROCEDURE TO pract1_ejercicio2;

CREATE TABLE Raza(
    Id_Raza INTEGER     NOT NULL,
    Raza    VARCHAR(50) NOT NULL,
    
    CONSTRAINT PK_Raza
        PRIMARY KEY (Id_Raza)

);

CREATE TABLE Estado_Mental(
    Id_Estado_Mental    INTEGER     NOT NULL,
    Estado_Mental       VARCHAR(50) NOT NULL,

    CONSTRAINT PK_Estado_Mental
        PRIMARY KEY (Id_Estado_Mental)

);

CREATE TABLE Profesion(
    Id_Profesion    INTEGER     NOT NULL,
    Profesion       VARCHAR(50) NOT NULL,
    
    CONSTRAINT PK_Profesion
        PRIMARY KEY (Id_Profesion)

);

CREATE TABLE  Tratamiento(
    Id_Tratamiento  INTEGER     NOT NULL,
    Tratamiento     VARCHAR(50) NOT NULL,

    CONSTRAINT PK_Tratamiento
        PRIMARY KEY (Id_Tratamiento)

);

CREATE TABLE Problema(
    Id_Problema INTEGER     NOT NULL,
    Problema    VARCHAR(50) NOT NULL,

    CONSTRAINT PK_Problema
        PRIMARY KEY (Id_Problema)
);

CREATE TABLE Estacion_Television(
    Id_Estacion INTEGER     NOT NULL,
    Estacion    VARCHAR(50) NOT NULL,

    CONSTRAINT PK_Estacion_Television
        PRIMARY KEY (Id_Estacion)
);

CREATE TABLE Pais(
    Id_Pais INTEGER     NOT NULL,
    Pais    VARCHAR(50) NOT NULL,

    CONSTRAINT PK_Pais
        PRIMARY KEY (Id_Pais)
);

CREATE TABLE  Persona(
    Id_Persona          INTEGER     NOT NULL,
    Nombre              VARCHAR(50) NOT NULL,
    Apellido            VARCHAR(50) NOT NULL,
    Fecha_Nacimiento    DATE        NOT NULL,
    Profesion           INTEGER     NOT NULL,
    
    CONSTRAINT PK_Persona
        PRIMARY KEY (Id_Persona),
    
    CONSTRAINT FK1_Persona
        FOREIGN KEY (Profesion)
            REFERENCES Profesion(Id_Profesion)
                ON DELETE CASCADE
        
);
    
CREATE TABLE Perro(
    Id_Perro        INTEGER     NOT NULL,
    Nombre          VARCHAR(50) NOT NULL,
    Edad            INTEGER     NOT NULL,
    Raza            INTEGER     NOT NULL,
    Estado_Mental   INTEGER     NOT NULL,
    Propietario     INTEGER     NOT NULL,

    CONSTRAINT PK_Perro
        PRIMARY KEY (Id_Perro),

    CONSTRAINT FK1_Perro
        FOREIGN KEY (Raza)
            REFERENCES Raza(Id_Raza)
                ON DELETE CASCADE,

    CONSTRAINT FK2_Perro
        FOREIGN KEY (Estado_Mental)
            REFERENCES Estado_Mental(Id_Estado_Mental)
                ON DELETE CASCADE,

    CONSTRAINT FK3_Perro
        FOREIGN KEY (Propietario)
            REFERENCES Persona(Id_Persona)
                ON DELETE CASCADE
        
);

CREATE TABLE Visita(
    Id_Visita   INTEGER     NOT NULL,
    Cliente     INTEGER     NOT NULL,
    Fecha       DATE        NOT NULL,
    Costo       FLOAT(2)    NOT NULL,
    
    CONSTRAINT PK_Visita
        PRIMARY KEY (Id_Visita),

    CONSTRAINT FK1_Visita
        FOREIGN KEY (Cliente)
            REFERENCES Persona(Id_Persona)
                ON DELETE CASCADE

);

CREATE TABLE Tratamiento_Perro(
    Perro       INTEGER NOT NULL,
    Problema    INTEGER NOT NULL,
    Tratamiento INTEGER NOT NULL,
    Fecha       DATE    NOT NULL,

    CONSTRAINT PK_Tratamiento_Perro
        PRIMARY KEY (Perro, Problema, Tratamiento),

    CONSTRAINT FK1_Tratamiento_Perro
        FOREIGN KEY (Perro)
            REFERENCES Perro(Id_Perro)
                ON DELETE CASCADE,

    CONSTRAINT FK2_Tratamiento_Perro
        FOREIGN KEY (Problema)
            REFERENCES Problema(Id_Problema)
                ON DELETE CASCADE,

    CONSTRAINT FK3_Tratamiento_Perro
        FOREIGN KEY (Tratamiento)
            REFERENCES Tratamiento(Id_Tratamiento)
                ON DELETE CASCADE

);

CREATE TABLE Transmision (
    Visita              INTEGER     NOT NULL,
    Estacion            INTEGER     NOT NULL,
    Pais                INTEGER     NOT NULL,
    Fecha_Transmision   DATE        NOT NULL,
    Numero_Espectadores INTEGER     NULL,
    
    CONSTRAINT PK_Transmision
        PRIMARY KEY (Visita, Estacion, Fecha_Transmision),

    CONSTRAINT FK1_Transmision
        FOREIGN KEY (Visita)
            REFERENCES Visita(Id_Visita)
                ON DELETE CASCADE,        

    CONSTRAINT FK2_Transmision
        FOREIGN KEY (Estacion)
            REFERENCES Estacion_Television(Id_Estacion)
                ON DELETE CASCADE,
                
    CONSTRAINT FK3_Transmision
        FOREIGN KEY (Pais)
            REFERENCES Pais(Id_Pais)
                ON DELETE CASCADE

);

CREATE OR REPLACE TRIGGER Validar_Edad
    BEFORE INSERT OR UPDATE
        ON Persona
            FOR EACH ROW 
BEGIN
    IF(TO_CHAR(CURRENT_DATE - :new.Fecha_Nacimiento,'YYYY') >= 18) THEN
        raise_application_error(20000, 'Fecha de Nacimiento no valida');
    END IF; 
END;
