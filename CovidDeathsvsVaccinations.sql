-- View the data with out null from CovidDeath tables
SELECT * 
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;

-- select the data that we will start with
SELECT location, date, total_cases, new_cases, population
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Total cases Vs total deaths
-- showing likelihood of daying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 death_percentage
FROM PortfolioProjects..CovidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2;

-- Total cases vs population
-- show shat percentage of population infected with covid
SELECT location, date, population, CAST(total_cases AS float) As total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2;

-- Conteries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT
-- showing continents with the hieghest death count per population
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Total Population vs Vaccinations
-- shows percentage of population that has recieved at leat one covid vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to Perform Calculation on Partition By in Pervious query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using TempTable to perform calculations on partion by in previous query
DROP TABLE IF EXISTS #PercentVaccinationPopulated
CREATE TABLE #PercentVaccinationPopulated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentVaccinationPopulated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

SELECT *, RollingPeopleVaccinated
FROM #PercentVaccinationPopulated

-- Creating view to store data for later visulaizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


SELECT *
FROM PercentPopulationVaccinated;