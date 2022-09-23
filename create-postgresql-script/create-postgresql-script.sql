-- Table: public.State

-- DROP TABLE IF EXISTS public."State";

CREATE TABLE IF NOT EXISTS public."State"
(
    "Id" uuid NOT NULL,
    "Name" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "Code" character(2) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "State_pkey" PRIMARY KEY ("Id")
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public."State"
    OWNER to omco;
	

-- Table: public.Country

-- DROP TABLE IF EXISTS public."Country";

CREATE TABLE IF NOT EXISTS public."Country"
(
    "Id" uuid NOT NULL,
    "Name" character varying(150) COLLATE pg_catalog."default" NOT NULL,
    "Code" character varying(10) COLLATE pg_catalog."default",
    CONSTRAINT "Country_pkey" PRIMARY KEY ("Id")
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public."Country"
    OWNER to omco;
	

-- Table: public.Customer

-- DROP TABLE IF EXISTS public."Customer";

CREATE TABLE IF NOT EXISTS public."Customer"
(
    "Id" uuid NOT NULL,
    "Name" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "StateId" uuid NOT NULL,
    "CountryId" uuid NOT NULL,
    "Address" character varying(250) COLLATE pg_catalog."default",
    "Address2" character varying(250) COLLATE pg_catalog."default",
    "Zip" character varying(50) COLLATE pg_catalog."default",
    "Phone" character varying(50) COLLATE pg_catalog."default",
    "MaxUsers" integer,
    "LogoUrl" character varying(250) COLLATE pg_catalog."default",
    CONSTRAINT "Customer_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "Country_fkey" FOREIGN KEY ("CountryId")
        REFERENCES public."Country" ("Id") MATCH FULL
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT "State_fkey" FOREIGN KEY ("StateId")
        REFERENCES public."State" ("Id") MATCH FULL
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public."Customer"
    OWNER to omco;
	
	
-- Table: public.Role

-- DROP TABLE IF EXISTS public."Role";

CREATE TABLE IF NOT EXISTS public."Role"
(
    "Id" uuid NOT NULL,
    "Name" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "Type" integer NOT NULL,
    CONSTRAINT "Role_pkey" PRIMARY KEY ("Id")
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public."Role"
    OWNER to omco;
	
	
-- Table: public.User

-- DROP TABLE IF EXISTS public."User";

CREATE TABLE IF NOT EXISTS public."User"
(
    "Id" uuid NOT NULL,
    "Email" character varying(250) COLLATE pg_catalog."default" NOT NULL,
    "Firstname" character varying(50) COLLATE pg_catalog."default" NOT NULL,
    "Lastname" character varying(50) COLLATE pg_catalog."default" NOT NULL,
    "CustomerId" uuid NOT NULL,
    "RoleId" uuid,
    CONSTRAINT "User_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "Customer_fkey" FOREIGN KEY ("CustomerId")
        REFERENCES public."Customer" ("Id") MATCH FULL
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT "Role_fkey" FOREIGN KEY ("RoleId")
        REFERENCES public."Role" ("Id") MATCH FULL
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public."User"
    OWNER to omco;
	
	
-- Table: public.Site

-- DROP TABLE IF EXISTS public."Site";

CREATE TABLE IF NOT EXISTS public."Site"
(
    "Id" uuid NOT NULL,
    "Name" character varying(200) COLLATE pg_catalog."default" NOT NULL,
    "CustomerId" uuid NOT NULL,
    "CountryId" uuid NOT NULL,
    "StateId" uuid NOT NULL,
    "Latittude" numeric,
    "Longitude" numeric,
    "Comission" date,
    "Timezone" character varying(10) COLLATE pg_catalog."default",
    CONSTRAINT "Site_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "Country_fkey" FOREIGN KEY ("CountryId")
        REFERENCES public."Country" ("Id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "Customer_fkey" FOREIGN KEY ("CustomerId")
        REFERENCES public."Customer" ("Id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "State_fkey" FOREIGN KEY ("StateId")
        REFERENCES public."State" ("Id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public."Site"
    OWNER to omco;
	
	
-- Table: public.Tracker

-- DROP TABLE IF EXISTS public."Tracker";

CREATE TABLE IF NOT EXISTS public."Tracker"
(
    "Id" uuid NOT NULL,
    "InstallDate" date,
    "Model" character varying(50) COLLATE pg_catalog."default",
    "Serial" character varying(50) COLLATE pg_catalog."default",
    "Part" character varying(50) COLLATE pg_catalog."default",
    "GroupId" uuid,
    "ParentNetId" uuid,
    "NetAddress" character varying(50) COLLATE pg_catalog."default",
    "SWVersion" character varying(25) COLLATE pg_catalog."default",
    "SiteId" uuid NOT NULL,
    CONSTRAINT "Tracker_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "Site_fkey" FOREIGN KEY ("SiteId")
        REFERENCES public."Site" ("Id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public."Tracker"
    OWNER to omco;