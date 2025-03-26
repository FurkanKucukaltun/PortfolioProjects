SELECT *
FROM `my-project-furkan.Covid_Data.covid_deaths`
ORDER BY 3,4;

/*
SELECT *
FROM `my-project-furkan.Covid_Data.covid_vaccinations`
ORDER BY 3,4
*/

-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `my-project-furkan.Covid_Data.covid_deaths`
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM `my-project-furkan.Covid_Data.covid_deaths`
WHERE total_cases <> 0
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths in Turkey
-- Showing likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM `my-project-furkan.Covid_Data.covid_deaths`
WHERE location like '%Turkey%' AND total_cases <> 0
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM `my-project-furkan.Covid_Data.covid_deaths`
WHERE location like '%Turkey%' AND total_cases <> 0
ORDER BY 1,2;
--ORDER BY  total_cases DESC;

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM `my-project-furkan.Covid_Data.covid_deaths`
WHERE total_cases <> 0 --AND location like '%Turkey%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

--Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM `my-project-furkan.Covid_Data.covid_deaths`
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC; 


-- LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continents with Highest Death Count per Population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM `my-project-furkan.Covid_Data.covid_deaths`
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Global Numbers
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM `my-project-furkan.Covid_Data.covid_deaths`
-- WHERE location like '%Turkey%' AND total_cases <> 0
WHERE continent is not null AND new_cases <> 0
-- GROUP BY date
ORDER BY 1,2;


-- Looking at Total Population vs Total Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM `my-project-furkan.Covid_Data.covid_deaths` dea
JOIN `my-project-furkan.Covid_Data.covid_vaccinations` vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


-- Use CTE (Common Table Expression) 

WITH PopvsVac --(Contienet,Location,Date,Population,New_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM `my-project-furkan.Covid_Data.covid_deaths` dea
JOIN `my-project-furkan.Covid_Data.covid_vaccinations` vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *,  (RollingPeopleVaccinated/population)*100
FROM PopvsVac;


--TEMP TABLE

CREATE TEMP TABLE PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM `my-project-furkan.Covid_Data.covid_deaths` dea
JOIN `my-project-furkan.Covid_Data.covid_vaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date;

SELECT *, (RollingPeopleVaccinated / population) * 100 AS VaccinationRate
FROM PercentPopulationVaccinated;

-- YOU CAN CREATE CTE USING "WITH" COMMAND
/*
WITH PercentPopulationVaccinated AS (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM `my-project-furkan.Covid_Data.covid_deaths` dea
    JOIN `my-project-furkan.Covid_Data.covid_vaccinations` vac
      ON dea.location = vac.location
      AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentVaccinated
FROM PercentPopulationVaccinated;
*/

/* THIS QUERY LINES IN COMMENT VALID FOR SQL Server, NOT FOR BIG QUERY
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TEMP TABLE #PercentPopulationVaccinated
(
  continent nvarchar(255),
  location nvarchar(255),
  Date datetime,
  Popuılation numeric,
  New_vaccinations numeric,
  RollingPeopleVaccinated numeric
)

INSERT INTO
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM `my-project-furkan.Covid_Data.covid_deaths` dea
JOIN `my-project-furkan.Covid_Data.covid_vaccinations` vac
  ON dea.location = vac.location
  and dea.date = vac.date

SELECT *,  (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated;
*/


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW `my-project-furkan.Covid_Data.PercentPopulationVaccinated` AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM `my-project-furkan.Covid_Data.covid_deaths` dea
JOIN `my-project-furkan.Covid_Data.covid_vaccinations` vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *
FROM `my-project-furkan.Covid_Data.PercentPopulationVaccinated`;

-- You can't create a table or view directly in BigQuery.
-- When using the CREATE VIEW command in BigQuery, you must explicitly specify which dataset the view will be created in.
-- Below query is for SQL Server. Not for BigQuery
/*
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM `my-project-furkan.Covid_Data.covid_deaths` dea
JOIN `my-project-furkan.Covid_Data.covid_vaccinations` vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent IS NOT NULL;
*/



