
SELECT *
FROM CovidProject.CovidDeaths
WHERE continent <> ''
order by 3,4


-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject.CovidDeaths
WHERE continent <> ''
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS DeathPercentage
FROM CovidProject.CovidDeaths
WHERE continent <> ''
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases / population)*100 AS PercentPopulationInfected
FROM CovidProject.CovidDeaths
WHERE continent <> ''
order by 1,2

-- Looking at countries Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population))*100 AS PercentPopulationInfected
FROM CovidProject.CovidDeaths
WHERE continent <> ''
group by location, population
order by PercentPopulationInfected DESC

-- Showing Counties with Highest Death Count per Population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidProject.CovidDeaths
WHERE continent <> ''
group by location
order by TotalDeathCount DESC

-- Let's break this down by Continent
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidProject.CovidDeaths
WHERE continent = ''
group by location
order by TotalDeathCount DESC

-- Showing continents with the highest death count per population
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidProject.CovidDeaths
WHERE continent <> ''
group by continent
order by TotalDeathCount DESC

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM CovidProject.CovidDeaths
WHERE continent <> ''
group by date
order by 1,2

-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidProject.CovidDeaths dea
JOIN CovidProject.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent <> ''
order by 2,3

-- USE CTE

With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
(
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (
		Partition by dea.location 
		order by dea.location, dea.date
	) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM CovidProject.CovidDeaths dea
JOIN CovidProject.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent <> ''
-- order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac 



USE CovidProject;
-- USE TEMP TABLE

-- Drop table if it exists
DROP TABLE IF EXISTS PercentPopulationVaccinated;

-- Create the table
CREATE TABLE PercentPopulationVaccinated (
    continent VARCHAR(255),
    location VARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

-- Insert cleaned data
INSERT INTO PercentPopulationVaccinated
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    CAST(NULLIF(vac.new_vaccinations, '') AS UNSIGNED) AS new_vaccinations,
    SUM(CAST(NULLIF(vac.new_vaccinations, '') AS UNSIGNED)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.date
    ) AS RollingPeopleVaccinated
FROM CovidProject.CovidDeaths dea
JOIN CovidProject.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent <> '';

-- Final result with percentage
SELECT 
    *, 
    (RollingPeopleVaccinated / population) * 100 AS PercentVaccinated
FROM PercentPopulationVaccinated;


-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinatedView AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidProject.CovidDeaths dea
JOIN CovidProject.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent <> ''
-- order by 2,3

