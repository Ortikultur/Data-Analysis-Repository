SELECT *
FROM CovidDeaths
Where continent is NOT NULL
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2 

-- total cases vs total deaths
-- shows the likelihood of dying if you contact covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercent
FROM CovidDeaths
WHERE location like 'France'
Order by 1,2


--total cases vs population
-- shows % of populations that got covid
SELECT location, date, total_cases, population, (total_deaths/population)*100 AS PercentPopulation
FROM CovidDeaths
Order by 1,2


--... countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100 ) AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY population, location
Order by PercentPopulationInfected DESC


-- countries with the highest death counts per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
Where continent is  NULL
GROUP BY location
Order by TotalDeathCount DESC

--- BREAKING IT DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
Where continent is not NULL
GROUP BY continent
Order by TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercent
FROM CovidDeaths
--WHERE location like 'France'
Where continent is NOT NULL
--GROUP BY date
Order by 1,2

-- Looking @ total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinATED
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
order by 2,3

-- USE CTE

WITH PopvsVac (Continent, location, date, population,new_vaccinations, RollingPeopleVaccinATED)
as

(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinATED
--(RollingPeopleVaccinATED/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
--order by 2,3
)

SELECT *, (RollingPeopleVaccinATED/population)*100
FROM PopvsVac




--- CREATING VIEWS

-- TEMP TABLES

CREATE TABLE #PercentPopulationVaccinated 
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinATED numeric )

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinATED
--(RollingPeopleVaccinATED/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
--order by 2,3

SELECT *, (RollingPeopleVaccinATED/population)*100
FROM #PercentPopulationVaccinated





--- CREATING VIEWS TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated as 

SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinATED
--(RollingPeopleVaccinATED/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
--order by 2,3


SELECT *
FROM PercentPopulationVaccinated