SELECT *
FROM ProjectCOVID19..CovidDeaths
ORDER BY 3,4

SELECT *
FROM ProjectCOVID19..CovidVaccinations
ORDER BY 3,4

--Data that we are going to be using

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM ProjectCOVID19..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)* 100 AS DeathPercentage
FROM ProjectCOVID19..CovidDeaths
ORDER BY 1,2


--Shows the likelihood of dying after contracting COVID-19 in India

SELECT location,date,new_cases,total_cases,new_deaths,total_deaths,(total_deaths/total_cases)* 100 AS DeathPercentage
FROM ProjectCOVID19..CovidDeaths
WHERE location LIKE 'India'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT location,date,population,total_cases,(total_cases/population)* 100 AS PercentPopulationInfected
FROM ProjectCOVID19..CovidDeaths
WHERE location LIKE 'India'
ORDER BY 1,2

--Looking at Countries with highest Infection Rate compared to Population

SELECT location,population,MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)* 100 AS PercentPopulationInfected
FROM ProjectCOVID19..CovidDeaths
GROUP BY location,population
ORDER BY PercentPopulationInfected desc

--Looking at India's Infection Rate compared to Population

SELECT location,population,MAX(total_cases) AS HighestInfectionCount,MAX(total_cases/population)* 100 AS PercentPopulationInfected
FROM ProjectCOVID19..CovidDeaths
WHERE location LIKE 'India'
GROUP BY location,population 

--Showing Countries with Highest Death Count per Population

SELECT location,population,MAX(total_deaths) AS TotalDeathCount,MAX(total_deaths/population)* 100 AS PercentPopulationDeath
FROM ProjectCOVID19..CovidDeaths
GROUP BY location,population
ORDER BY PercentPopulationDeath DESC

--Showing India's Death Count per Population

SELECT location,population,MAX(total_deaths) AS TotalDeathCount,MAX(total_deaths/population)* 100 AS DeathPerPopulaton
FROM ProjectCOVID19..CovidDeaths
WHERE location LIKE 'India'
GROUP BY location,population 

--Lets break things down by continent..

--Showing continents with the highest death count per population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM ProjectCOVID19..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- JOINING THE TWO TABLES

SELECT *
FROM ProjectCOVID19..CovidDeaths dea
JOIN ProjectCOVID19..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations 

--Using CTE

WITH PopulationvsVaccinations (continent,location,date,population,new_vaccinations,RollingPeoplevaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM ProjectCOVID19..CovidDeaths dea
JOIN ProjectCOVID19..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeoplevaccinated/population)*100
FROM PopulationvsVaccinations

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM ProjectCOVID19..CovidDeaths dea
JOIN ProjectCOVID19..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
SELECT *, (RollingPeoplevaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated 
AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM ProjectCOVID19..CovidDeaths dea
JOIN ProjectCOVID19..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *
FROM PercentPopulationVaccinated