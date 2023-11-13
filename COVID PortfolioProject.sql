select *
from CovidVaccinations
order by 3,4

-- Select Data that we are going to be using
SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2 

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
FROM CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2 

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 as PopulationPercentage
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY 4 DESC

-- Showing Countries with the Highest Death Count per Population
--Convert total_deaths from nvarchar to INT with CAST
SELECT Location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM CovidDeaths
WHERE Continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Break down by continent
-- is null because then the location is the continent
SELECT Location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM CovidDeaths
WHERE Continent is null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--video example of break down by continent
--Showing continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS breakdown by DATE
SELECT date, SUM(new_cases) AS total_cases, 
SUM(CAST(new_deaths AS INT)) AS total_deaths,
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentageGlobal
FROM CovidDeaths
where continent is not null
GROUP BY DATE
ORDER BY 1,2 desc

-- GLOBAL NUMBERS total
SELECT SUM(new_cases) AS total_cases, 
SUM(CAST(new_deaths AS INT)) AS total_deaths,
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentageGlobal
FROM CovidDeaths
where continent is not null
ORDER BY 1,2 desc


-- Looking at Total Population vs Vaccinations
--CONVERT, same as CAST different way
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPPLVaccinated
--,(RollingPPLVaccinated/population)*100
-- partition to add consecuvtive new vaccinations by location, rolling count by location and date
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
	ORDER BY 2,3


--USE CTE
---need CTE to reference column you made in this way
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPPLVaccinated
--,(RollingPPLVaccinated/population)*100
-- partition to add consecuvtive new vaccinations by location, rolling count by location and date
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3
	)

	SELECT *, (RollingPeopleVaccinated/Population)*100
	FROM PopvsVac


--TEMP Table
DROP Table if exists #PercentPopulationVaccinated 
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255), 
Date datetime, 
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPPLVaccinated
--,(RollingPPLVaccinated/population)*100
-- partition to add consecuvtive new vaccinations by location, rolling count by location and date
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualizations
	CREATE VIEW PercentPopulationVaccinated AS
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPPLVaccinated
--,(RollingPPLVaccinated/population)*100
-- partition to add consecuvtive new vaccinations by location, rolling count by location and date
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3


	SELECT *
	FROM PercentPopulationVaccinated