  #------------------------------------------------------------------------------#
#                         MODIS MOD13Q1 DATA
#------------------------------------------------------------------------------#

load("~/ownCloud/PROFOUND_Data/Processed/RData/MODIS_MOD13Q1_Data.RData")
names(MODIS_MOD13Q1_Data)
# Target variables
#variables_names <- c( "RCP","year", "CO2")
# Columns DB
columns <- c("record_id",  "site_id", "date", "day", "mo", "year","ndvi16", "evi16",
             "ndvi16_qc", "evi16_qc")
# Load libraries
require(sqldf)
require(DBI)
require(RSQLite)
# open connection to DB
db <- dbConnect(SQLite(), dbname= myDB)
# create table in DB (cant type minus)
if ( "MODIS_MOD13Q1_master" %in% dbListTables(db)){
  dbSendQuery(db, "DROP TABLE MODIS_MOD13Q1_master")}

dbSendQuery(conn = db,
            "CREATE TABLE MODIS_MOD13Q1_master
            (record_id INTEGER NOT NULL,
            site_id INTEGER NOT NULL,
            date TEXT NOT NULL, 
            day INTEGER NOT NULL,
            mo INTEGER NOT NULL,
            year INTEGER NOT NULL, 
            ndvi16 REAL, 
            evi16 REAL,
            ndvi16_qc INTEGER,
            evi16_qc INTEGER,
            PRIMARY KEY (record_id),
            FOREIGN KEY (site_id) REFERENCES SITESID_master(site_id)
            )")

# Check the table
dbListTables(db) # The tables in the database
dbListFields(db, "MODIS_MOD13Q1_master") # The fields in the table
## Close connnection to db
dbDisconnect(db)
# dbSendQuery(db, "DROP TABLE CO2")
#id <- 0
# Loop over files adds data to DB, could also add it to list and then do.call(rbind, listDf)
#for (i in 1:length(MODIS16_DATA)){
df <- MODIS_MOD13Q1_Data
df$record_id <- c(1:length(df[,1]))
# open connection to DB
db <- dbConnect(SQLite(), dbname= myDB)
dbWriteTable(db, "MODIS_MOD13Q1_master", df[,columns], append=TRUE, row.names = FALSE)
dbDisconnect(db)
# reset the id values
#id <- id+length(df$Site)
#}
# create index
db <- dbConnect(SQLite(), dbname=myDB)
# create index for variables we are going to query: so far location, gcm, rcp
# --> change names to include the table
dbGetQuery(db,"CREATE INDEX index_MODIS_MOD13Q1_master_site_id ON MODIS_MOD13Q1_master(site_id)")
dbDisconnect(db)

