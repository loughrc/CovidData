/*
Covid 19 Data Exploration

The data origin is https://ourworldindata.org/covid-deaths and the data itself contains covid infection information for all countries worldwide since 28 January 2020.
The data arrives as one csv file.
It is split into two files using Microsoft Excel (each containing different features), which are used to create two explicit tables, CovidVaccinations and CovidDeaths.

Skills used: Table Creation, Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views.
*/

CREATE DATABASE covid;

USE covid;

-- Create Tables and populate them with data

DROP TABLE IF EXISTS covid.CovidVaccinations; 
CREATE TABLE covid.CovidVaccinations (
iso_code VARCHAR(15),
continent VARCHAR(20),
location VARCHAR(40),
date DATE,
new_tests INT,
total_tests INT,
total_tests_per_thousand FLOAT,
new_tests_per_thousand FLOAT,
new_tests_smoothed INT,
new_tests_smoothed_per_thousand FLOAT,
positive_rate FLOAT,
tests_per_case FLOAT,
tests_units VARCHAR(20),
total_vaccinations INT,
people_vaccinated INT,
people_fully_vaccinated INT,
new_vaccinations INT,
new_vaccinations_smoothed FLOAT,
total_vaccinations_per_hundred FLOAT,
people_vaccinated_per_hundred FLOAT,
people_fully_vaccinated_per_hundred FLOAT,
new_vaccinations_smoothed_per_million INT,
stringency_index FLOAT,
population_density FLOAT,
median_age FLOAT,
aged_65_older FLOAT,
aged_70_older FLOAT,
gdb_per_capita FLOAT,
extreme_poverty FLOAT,
cardiovasc_death_rate FLOAT,
diabetes_prevalence FLOAT,
female_smokers FLOAT,
male_smokers FLOAT,
handwashing_facilities FLOAT,
hospital_beds_per_thousand FLOAT,
life_expectancy FLOAT,
human_development_index FLOAT,
PRIMARY KEY (iso_code, date)
);

LOAD DATA INFILE '/var/lib/mysql-files/CovidVaccinations2.csv' 
INTO TABLE covid.CovidVaccinations 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

DROP TABLE IF EXISTS covid.CovidDeaths;
CREATE TABLE covid.CovidDeaths (
iso_code VARCHAR(15),
continent VARCHAR(20),
location VARCHAR(40),
date DATE,
population BIGINT,
total_cases INT,
new_cases INT,
new_cases_smothered FLOAT,
total_deaths INT,
new_deaths INT,
new_deaths_smoothed FLOAT,
total_cases_per_million FLOAT,
new_cases_per_million FLOAT,
new_cases_smoothed_per_million FLOAT,
total_deaths_per_million FLOAT,
new_deaths_per_million FLOAT,
new_deaths_smoothed_per_million FLOAT,
reproduction_rate FLOAT,
icu_patients INT,
icu_patients_per_million FLOAT,
hosp_patients INT,
hosp_patients_per_million FLOAT,
weekly_icu_admissions FLOAT,
weekly_icu_admissions_per_million FLOAT,
weekly_hosp_admissions FLOAT,
weekly_hosp_admissions_per_million FLOAT,
PRIMARY KEY (iso_code, date)
);

LOAD DATA INFILE '/var/lib/mysql-files/CovidDeaths2.csv' 
INTO TABLE covid.CovidDeaths 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- Select and view a small number of columns from the CovidDeaths table

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid.CovidDeaths
ORDER BY 1,2;

-- Total Cases vs Total Deaths (for all countries in dataset)
-- i.e. Shows a rolling rough percentage of the confirmed cases that resulted in death

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Rate
FROM covid.CovidDeaths
ORDER BY 1,2;


-- Show the death rate for a specific country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Rate
FROM covid.CovidDeaths
WHERE location = "Ireland"
ORDER BY 1,2;


-- Total Cases vs Population
-- Shows what percentage of population were confirmed cases of covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS Infection_Percentage
FROM covid.CovidDeaths
WHERE location = "Ireland"
ORDER BY 1,2;


-- Order countries by those with highest infection rate compared to that country's population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as Infection_Percentage
FROM covid.CovidDeaths
GROUP BY location, population
ORDER BY Infection_Percentage DESC;


-- Shows which countries have the highest death count per population

SELECT location, MAX(total_deaths) AS TotalDeathCount, MAX((total_deaths/population))*100 AS Death_Percentage
FROM covid.CovidDeaths
GROUP BY location, population
ORDER BY Death_Percentage DESC;


-- Show which countries have the highest death count overall

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM covid.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Break down percentage of deaths per population by continent rather than by country

SELECT location, MAX(total_deaths) AS TotalDeathCount, MAX((total_deaths/population))*100 as Death_Percentage
FROM covid.CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY Death_Percentage DESC;


-- Show total deaths by continent

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM covid.CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Global Numbers 
-- Show numbers for whole world, grouped by date starting from January 2020

SELECT date, SUM(new_cases) as new_cases, SUM(new_deaths) as new_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM covid.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;


-- Show total current numbers for whole world

SELECT SUM(new_cases) AS total_Cases, SUM(new_deaths) AS total_Deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM covid.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Look at Total Population vs Vaccinations
-- Join the CovidDeaths table with the CovidVaccinations table based on common columns

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM covid.CovidDeaths dea
JOIN covid.CovidVaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


-- New vaccinations
-- Partition by location means total number of vaccinations will reset when the location changes
-- We need to order by both location and date for the numbers to be added

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS rolling_people_vaccinated 
FROM covid.CovidDeaths dea
JOIN covid.CovidVaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


-- If we want to get the rolling percentage of people vaccinated, we can use either CTE or a temp table 
-- with which we can calculate the rolling_people_vaccinated figure as a percentage of a country's population
-- First I will use CTE

WITH percent_population_vaccinated (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS rolling_people_vaccinated 
FROM covid.CovidDeaths dea
JOIN covid.CovidVaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_people_vaccinated/population)*100 AS rolling_percentage_vaccinated
FROM percent_population_vaccinated;


-- Retrieve rolling_people_vaccinated figures but this time using a temp table

DROP TABLE IF EXISTS percent_population_vaccinated;
CREATE TEMPORARY TABLE percent_population_vaccinated (
continent VARCHAR(20),
location VARCHAR(40),
date DATE,
population INT,
new_vaccinations INT,
rolling_people_vaccinated INT
);

INSERT INTO percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS rolling_people_vaccinated 
FROM covid.CovidDeaths dea
JOIN covid.CovidVaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (rolling_people_vaccinated/population)*100 AS rolling_percentage_vaccinated
FROM percent_population_vaccinated;


-- Create View of data for visualisation at a later stage

DROP VIEW IF EXISTS percent_population_vaccinated_view;
CREATE VIEW percent_population_vaccinated_view AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS rolling_people_vaccinated 
FROM covid.CovidDeaths dea
JOIN covid.CovidVaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- Display data from view

SELECT *
FROM percent_population_vaccinated_view;


