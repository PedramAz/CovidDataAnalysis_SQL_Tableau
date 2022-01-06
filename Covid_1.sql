SELECT * FROM CovidPF..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4


-- select data that we are going to use 
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidPF..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Looking at the total cases vs. total deaths 
-- Shows the likelihood of dying if you contract covid at any country 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidPF..CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY 1, 2

-- Looking at the total cases vs. population 
-- Shows what percentage of population contracted covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
FROM CovidPF..CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY 1, 2

-- Looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases), MAX((total_cases/population))*100 as HighestInfectionCount
FROM CovidPF..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestInfectionCount DESC


-- Showing the countries with the highest death count
-- total_deaths column had type issue so we had to CAST it as INTEGER 
SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidPF..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- To breakdown the TotalDeathCount by continent
-- Showing the continets with the highest Death count

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidPF..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers 
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage  
FROM CovidPF..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Global Numbers by day
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage  
FROM CovidPF..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2


-- JOIN Deaths table with Vaccination table 
SELECT * 
FROM CovidPF..CovidDeaths dea
JOIN CovidPF..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

-- Looking at total population vs. vaccination
-- Create a rolling count column 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
FROM CovidPF..CovidDeaths dea
JOIN CovidPF..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- USE CTE 
-- To be able to add the newly created column to our overal results table 

WITH PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
FROM CovidPF..CovidDeaths dea
JOIN CovidPF..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated
FROM PopVsVac

-- Create a VIEW to store data for further visualizations
CREATE VIEW PercentPopulationVaccinated as 
WITH PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
FROM CovidPF..CovidDeaths dea
JOIN CovidPF..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated
FROM PopVsVac







