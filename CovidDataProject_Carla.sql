
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

-- Looking at total cases vs total deaths --
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPerc
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPerc
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like 'Portugal'
ORDER BY 1,2

-- Looking at Total Cases vs Population in Portugal--
SELECT location, date, total_cases, population, (total_cases/population)*100 as Incid
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like 'Portugal'
ORDER BY 1,2

-- Looking at Countries with Highest infection Rate compared to Population --
SELECT location, population, max(total_cases) as highestInfectionCount, Max((total_cases/population))*100 as Incid
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY Location, Population
ORDER BY 4 desc

-- Showing Countries with Highest Death Count per Population --
SELECT location, population, max(total_deaths) as highestDeathCount, Max((total_deaths/population))*100 as Incid
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent is not null
GROUP BY Location, Population
ORDER BY 4 desc

-- Showing Continents with the Highest Death Count per Population -- 
SELECT location, max(total_deaths) as highestDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent is null
GROUP BY location
ORDER BY 2 DESC


-- Global Numbers --
SELECT date, SUM(new_cases) as newCases, SUM(new_deaths) as newDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercent
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent is not null
GROUP by date
ORDER BY 1,2

-- Percentage of Death across the world --
SELECT  SUM(new_cases) as newCases, SUM(new_deaths) as newDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercent
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent is not null
ORDER BY 1,2

-- JOIN Locations with Deaths and Vaccination -- 
SELECT *
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date 

-- LOOKING AT TOTAL POPULATION VS VACCINATIONS --
SELECT dea.continent, dea.location, dea.date, dea.population, vac.total_vaccinations, (vac.total_vaccinations/dea.population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not null
ORDER BY 1,2,3

-- LOOKING AT NEW VACCINATIONS -- 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not null
ORDER BY 1,2,3

-- TOTAL VACCINATIONS WITH SUM NEW VACCINATIONS -- 

	-- USE CTE TO BE ABLE TO USE RollingPeopleVaccinated --

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not null
)
SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- USING TEMP TABLE --

DROP TABLE if exists #PercentPopulationVacc --If we need to change the query--
CREATE TABLE #PercentPopulationVacc
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVacc
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not null


SELECT * , (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVacc


-- % of Population fully vacinated --
SELECT dea.continent, dea.location, dea.date, dea.population, vac.people_fully_vaccinated, (vac.people_fully_vaccinated/dea.population) as PercPeopleVacc
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not null 
ORDER BY 1,2,3


--Creating view to store data for later visualizations--
CREATE VIEW PopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not null

SELECT *
FROM PopulationVaccinated 

CREATE VIEW CovidDeaths as 
SELECT location, population, max(total_deaths) as highestDeathCount, Max((total_deaths/population))*100 as Incid
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent is not null
GROUP BY Location, Population

SELECT *
FROM CovidDeaths 


-- Tableau queries for visualization --

--1.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

-- 5. Evolution of the pandemic in Portugal - Effects of vaccination

SELECT dea.date, dea.location, dea.new_cases, dea.new_deaths, vac.people_fully_vaccinated, (vac.people_fully_vaccinated/dea.population) as PercPeopleVacc
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not null AND dea.location = 'Portugal'
ORDER BY 1,2
