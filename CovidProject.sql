--SELECT *
--FROM CovidProject..CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM CovidProject..CovidVaccinations
--ORDER BY 3,4

--SELECTED DATA TO BE USED

--SELECT location,date,total_cases,new_cases,total_deaths,population
--FROM CovidProject..CovidDeaths
--ORDER BY 1,2

--TOTAL CASES VS TOTAL DEATHS

--SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)
--FROM CovidProject..CovidDeaths
--ORDER BY 1,2

--LIKEHOOD OF DYING IF YOU CONTACTED COVID IN NIGERIA
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE location like 'Nigeria'
ORDER BY 1,2

--TOTAL CASE VS TOTAL POPULATION IN NIGERIA
SELECT location,date,population,total_cases,(total_cases/population)*100 AS PercentagePopulationInfected
FROM CovidProject..CovidDeaths
WHERE location like 'Nigeria'
ORDER BY 1,2

--COUNTRIES WITH HIGHEST INFECTION RATE RELATIVE TO POPULATION
SELECT location, population,MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM CovidProject..CovidDeaths
--WHERE location like 'Nigeria'
GROUP BY location,population
ORDER BY PercentagePopulationInfected DESC

--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location,MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
--WHERE location like 'Nigeria'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT continent,MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS
SELECT date,sum(new_cases) AS total_cases,SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
--WHERE location like 'Nigeria'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--TOTAL WORLD NUMBERS OF CASES ,DEATH AND DEATHPERCENTAGE
SELECT sum(new_cases) AS total_cases,SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
--WHERE location like 'Nigeria'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--JOIN COVIDDEATH TABLE TO COVIDVACCINATION
SELECT*
FROM CovidProject..CovidDeaths DEA
JOIN CovidProject..CovidVaccinations VAC
 ON DEA.date = VAC.date
 AND DEA.location = VAC.location

 --SELECTING COLUMNS FROM JOINT TABLE
 SELECT*
FROM CovidProject..CovidDeaths DEA
JOIN CovidProject..CovidVaccinations VAC
 ON DEA.date = VAC.date
 AND DEA.location = VAC.location

 --TOTAL POPULATION VS VACCINATION
 SELECT DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations
FROM CovidProject..CovidDeaths DEA
JOIN CovidProject..CovidVaccinations VAC
 ON DEA.date = VAC.date
 AND DEA.location = VAC.location
 WHERE DEA.continent is not null
 ORDER BY 1,2,3

 SELECT DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations
 ,SUM(CONVERT(int, VAC.new_vaccinations)) OVER(PARTITION BY DEA.location ORDER BY DEA.location,DEA.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths DEA
JOIN CovidProject..CovidVaccinations VAC
 ON DEA.date = VAC.date
 AND DEA.location = VAC.location
 WHERE DEA.continent is not null
 ORDER BY 2,3


--USE CTE

WITH PopvsVac (Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(
 SELECT DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations
 ,SUM(CONVERT(int, VAC.new_vaccinations)) OVER(PARTITION BY DEA.location ORDER BY DEA.location,DEA.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths DEA
JOIN CovidProject..CovidVaccinations VAC
 ON DEA.location = VAC.location
 AND DEA.date = VAC.date
 WHERE DEA.continent is not null
 
 )

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE 
DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
 SELECT DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations
 ,SUM(CONVERT(int, VAC.new_vaccinations)) OVER(PARTITION BY DEA.location ORDER BY DEA.location,DEA.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths DEA
JOIN CovidProject..CovidVaccinations VAC
 ON DEA.location = VAC.location
 AND DEA.date = VAC.date
 WHERE DEA.continent is not null


 SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



--CREATE VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create View PercentPopulationVaccinated as
SELECT DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations
 ,SUM(CONVERT(int, VAC.new_vaccinations)) OVER(PARTITION BY DEA.location ORDER BY DEA.location,DEA.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths DEA
JOIN CovidProject..CovidVaccinations VAC
 ON DEA.date = VAC.date
 AND DEA.location = VAC.location
 WHERE DEA.continent is not null
 --ORDER BY 2,3

select *
from PercentPopulationVaccinated