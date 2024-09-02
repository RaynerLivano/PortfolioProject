SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL 
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--SELECT DATA
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Indonesia%' AND continent is NOT NULL 
ORDER BY 1,2

--Looking at Total cases vs Population
SELECT location, date, total_cases,population, (total_cases/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Indonesia%' AND continent is NOT NULL 
ORDER BY 1,2

--Looking at Countris with Highest Infection Rate camppared to Population
SELECT location, population, MAX(total_cases) as HighesInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Indonesia%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC

--By Continent

--Showing Continents with highest death count
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT		 SUM(new_cases) as total_cases, 
			 SUM(CAST (new_deaths as int)) as total_deaths, 
			 SUM(CAST(new_deaths as int))/
			 SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL 
--GROUP BY date
ORDER BY 1,2

--Total Population vs vaccinations

SELECT dea.continent, vac.location, vac.date, vac.population, dea.new_vaccinations,
	SUM(CONVERT(int,dea.new_vaccinations)) OVER (Partition BY vac.Location ORDER BY vac.location, vac.date) 
	AS RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidVaccinations dea
JOIN PortfolioProject..CovidDeaths vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE vac.continent is NOt NULL
ORDER BY 2, 3

--CTE
WITH PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, vac.location, vac.date, vac.population, dea.new_vaccinations,
	SUM(CONVERT(int,dea.new_vaccinations)) OVER (Partition BY vac.Location ORDER BY vac.location, vac.date) 
	AS RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidVaccinations dea
JOIN PortfolioProject..CovidDeaths vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE vac.continent is NOt NULL
--ORDER BY 2, 3
)
 
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac

--Temp Table
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,  
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, vac.location, vac.date, vac.population, dea.new_vaccinations,
	SUM(CONVERT(int,dea.new_vaccinations)) OVER (Partition BY vac.Location ORDER BY vac.location, vac.date) 
	AS RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidVaccinations dea
JOIN PortfolioProject..CovidDeaths vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE vac.continent is NOt NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--VIEW for visualization
CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, vac.location, vac.date, vac.population, dea.new_vaccinations,
	SUM(CONVERT(int,dea.new_vaccinations)) OVER (Partition BY vac.Location ORDER BY vac.location, vac.date) 
	AS RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidVaccinations dea
JOIN PortfolioProject..CovidDeaths vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE vac.continent is NOt NULL
--ORDER BY 2, 3
